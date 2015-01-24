class Sentence < ActiveRecord::Base
  include Metadatable
  include Readability

  belongs_to :ontology
  has_and_belongs_to_many :symbols, class_name: 'OntologyMember::Symbol'
  has_many :translated_sentences, dependent: :destroy
  default_scope where(imported: false, type: nil)

  attr_accessible :locid

  def hierarchical_class_names
    match = self.text.match(%r{
      \s*
      Class:
      \s*
      (?:
       <(?<first_class>.+)>|
       (?<first_class>.+)
      )
      \s*
      SubClassOf:
      \s*
      (?:
       <(?<second_class>.+)>|
       (?<second_class>.+)
      )
      \s*}x)
    if match
      [match[:first_class].strip, match[:second_class].strip]
    else
      []
    end
  end

end
