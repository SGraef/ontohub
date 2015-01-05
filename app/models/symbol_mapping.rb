class EntityMapping < ActiveRecord::Base
  belongs_to :source, class_name: "Symbol"
  belongs_to :target, class_name: "Symbol"
  belongs_to :mapping
  attr_accessible :mapping, :source, :target
  KINDS = %w( subsumes is-subsumed equivalent incompatible has-instance instance-of default-relation )

  def to_s
   "#{self.source} → #{self.target}"
  end

  def apply(sentence)
    sentence.text.gsub(source.name, target.name)
  end

  def applicable?(sentence)
    if sentence.is_a?(TranslatedSentence)
      mapping = sentence.symbol_mapping
      symbol_ids = [mapping.source_id, mapping.target_id]
    else
      symbol_ids = sentence.symbols.pluck(:id)
    end
    symbol_ids.include?(self.source_id)
  end

end
