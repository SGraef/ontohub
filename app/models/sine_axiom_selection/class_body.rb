module SineAxiomSelection::ClassBody
  extend ActiveSupport::Concern

  included do
    acts_as :axiom_selection

    attr_accessible :commonness_threshold, :depth_limit, :tolerance
    has_many :sine_symbol_commonnesses, dependent: :destroy
    has_many :sine_symbol_axiom_triggers, dependent: :destroy

    validates_numericality_of :commonness_threshold,
                              greater_than_or_equal_to: 0,
                              only_integer: true
    # Special case: The depth limit of -1 is considered to be infinite.
    validates_numericality_of :depth_limit,
                              greater_than_or_equal_to: -1,
                              only_integer: true
    validates_numericality_of :tolerance, greater_than_or_equal_to: 1

    delegate :goal, :ontology, :lock_key, :mark_as_finished!, :other_finished_axiom_selections,
             :preparation_time, :selection_time, :record_time, to: :axiom_selection
  end

  TIMEOUT_PREPARATION = 60.minutes
  TIMEOUT_SELECTION = 2.minutes
  CODE_TIMEOUT_PREPARATION = -1
  CODE_TIMEOUT_SELECTION = -2

  def prepare
    perform(TIMEOUT_PREPARATION, CODE_TIMEOUT_PREPARATION, :preparation_time) do
      preprocess
    end
  end

  def call
    perform(TIMEOUT_SELECTION, CODE_TIMEOUT_SELECTION, :selection_time) do
      select_axioms
      mark_as_finished!
    end
  end

  # This can't be made a 'has one through' association because the
  # `axiom_selection` association is polymorphic.
  def sine_symbol_commonnesses
    SineSymbolCommonness.where(axiom_selection_id: axiom_selection)
  end

  # This can't be made a 'has one through' association because the
  # `axiom_selection` association is polymorphic.
  def sine_symbol_axiom_triggers
    SineSymbolAxiomTrigger.where(axiom_selection_id: axiom_selection)
  end

  protected

  def perform(timeout, timeout_code, time_recording_field)
    Semaphore.exclusively(lock_key) do
      if !finished
        begin
          record_time(time_recording_field) do
            Timeout::timeout(timeout) do
              transaction do
                yield
              end
            end
          end
        rescue Timeout::Error
          save_on_timeout(timeout_code, time_recording_field)
          raise
        end
      elsif send(time_recording_field) == timeout_code
        raise 'previous execution expired'
      end
    end
  end

  def save_on_timeout(timeout_code, time_recording_field)
    send("#{time_recording_field}=", timeout_code)
    axiom_selection.mark_as_finished!
    save!
    axiom_selection.save!
  end

  def preprocess
    unless other_finished_axiom_selections(self.class).any?
      calculate_commonness_table
      calculate_symbol_axiom_trigger_table
    end
  end

  def calculate_commonness_table
    ontology.symbols.each { |symbol| calculate_commonness(symbol) }
  end

  def calculate_commonness(symbol)
    ssc = sine_symbol_commonnesses.
      where(symbol_id: symbol.id).first_or_initialize
    unless ssc.commonness
      ssc.commonness = query_commonness(symbol)
      ssc.save!
    end
  end

  def query_commonness(symbol)
    ontology.all_axioms.joins(:symbols).where(:'symbols.id' => symbol.id).count
  end

  def calculate_symbol_axiom_trigger_table
    ontology.all_axioms.each do |axiom|
      axiom.symbols.each do |symbol|
        calculate_symbol_axiom_trigger(symbol, axiom)
      end
    end
  end

  def calculate_symbol_axiom_trigger(symbol, axiom)
    ssat = sine_symbol_axiom_triggers.
      where(symbol_id: symbol.id,
            axiom_id: axiom.id).first_or_initialize
    unless ssat.tolerance
      ssat.tolerance = needed_tolerance(symbol, axiom)
      ssat.save!
    end
  end

  def needed_tolerance(symbol, axiom)
    lcs_commonness = commonness_of_least_common_symbol(axiom)
    sym_commonness = symbol.sine_symbol_commonness.commonness
    sym_commonness.to_f / lcs_commonness.to_f
  end

  def least_common_symbol(axiom)
    axiom.symbols.includes(:sine_symbol_commonness).
      order('sine_symbol_commonnesses.commonness ASC').first
  end

  def commonness_of_least_common_symbol(axiom)
    least_common_symbol(axiom).sine_symbol_commonness.commonness
  end

  def select_axioms
    @selected_axioms = triggered_axioms_by_commonness_threshold.to_a
    select_new_axioms(goal, 0)
    self.axioms = @selected_axioms.uniq
  end

  def select_new_axioms(sentence, current_depth)
    return if depth_limit_reached?(current_depth)
    new_axioms = select_axioms_by_sentence(sentence) - @selected_axioms
    @selected_axioms += new_axioms
    new_axioms.each { |axiom| select_new_axioms(axiom, current_depth + 1) }
  end

  def select_axioms_by_sentence(sentence)
    sentence.symbols.map { |symbol| triggered_axioms(symbol) }.flatten
  end

  def triggered_axioms(symbol)
    Axiom.unscoped.joins(:sine_symbol_axiom_triggers).
      where('sine_symbol_axiom_triggers.symbol_id = ?', symbol.id).
      where('sine_symbol_axiom_triggers.tolerance <= ?', tolerance)
  end

  def triggered_axioms_by_commonness_threshold
    Axiom.unscoped.joins(:symbols).
      where('symbols.id' => OntologyMember::Symbol.
        where(ontology_id: ontology.id).joins(:sine_symbol_commonness).
        where('sine_symbol_commonnesses.commonness < ?', commonness_threshold).
        map(&:id))
  end

  def depth_limit_reached?(current_depth)
    depth_limited? && current_depth >= depth_limit
  end

  def depth_limited?
    depth_limit != -1
  end
end