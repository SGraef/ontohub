module OntologyVersion::Parsing
  extend ActiveSupport::Concern

  included do
    @queue = 'hets'

    attr_accessor :fast_parse
    attr_accessor :files_to_parse_afterwards
  end

  def parse(refresh_cache: false, structure_only: self.fast_parse,
            files_to_parse_afterwards: self.files_to_parse_afterwards)
    files_to_parse_afterwards ||= []
    update_state! :processing

    do_or_set_failed do
      # run hets if necessary
      cmd, input_io = generate_xml(structure_only: structure_only)
      return if cmd == :abort

      # Import version
      ontology.import_version(self, pusher, input_io)
      retrieve_available_provers_for_self_and_children
      prepare_axiom_selections
      update_states_for_self_and_children(:done)
    end

    files_to_parse_afterwards.each do |path|
      ontology_version_options = OntologyVersionOptions.new(path, pusher)
      version = OntologySaver.new(repository).
        save_ontology(commit_oid, ontology_version_options)
    end
  end

  # generate XML by passing the raw ontology to Hets
  def generate_xml(structure_only: false)
    input_io = Hets.parse_via_api(ontology, ontology.hets_options,
                                  structure_only: structure_only)
    [:all_is_well, input_io]
  end

  def parse_full(files_to_parse_afterwards = [])
    parse(structure_only: false, files_to_parse_afterwards: files_to_parse_afterwards)
  end

  def parse_fast(files_to_parse_afterwards = [])
    parse(structure_only: true, files_to_parse_afterwards: files_to_parse_afterwards)
  end

  def prepare_axiom_selections
    # To compute all frequent symbol sets and all SInE related association
    # objects, it suffices to create a SInE-Fresym axiom selection and prepare
    # it, because that selection needs association objects of all selection
    # methods.
    if theorem = ontology.theorems.first
      proof_attempt_configuration =
        ProofAttemptConfiguration.new(timeout: nil,
                                      prover_id: Prover.first.id)
      proof_attempt =
        ProofAttempt.new(proof_status_id: 'OPN',
                         sentence_id: theorem.id,
                         proof_attempt_configuration_id: proof_attempt_configuration.id)
      axiom_selection_method = :sine_fresym_axiom_selection
      axiom_selection =
        SineFresymAxiomSelection.new(commonness_threshold: 1,
                                     depth_limit: nil,
                                     tolerance: 1,
                                     minimum_support: 1,
                                     minimum_support_type: :absolute,
                                     symbol_set_tolerance: 1)
        axiom_selection.prepare
        axiom_selection.save!
    end
  end

  def retrieve_available_provers_for_self_and_children
    retrieve_available_provers
    if ontology.distributed?
      ontology.children.each do |child|
        child.versions.find_by_commit_oid(commit_oid).
          try(:retrieve_available_provers)
      end
    end
  end

  def retrieve_available_provers
    hets_options = Hets::ProversOptions.new(**ontology.hets_options.options,
                                            ontology: ontology)
    provers_io = Hets.provers_via_api(ontology, hets_options)
    Hets::Provers::Importer.new(self, provers_io).import
  end

  def update_states_for_self_and_children(state)
    update_state!(state)
    ontology.reload.children.each do |child|
      child.versions.where(commit_oid: commit_oid).first.update_state!(state)
      child.versions.where(commit_oid: commit_oid).first.save!
    end
  end
end
