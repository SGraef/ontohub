class SymbolGroup < ActiveRecord::Base
  extend Dagnabit::Vertex::Activation
  belongs_to :ontology
  has_many :symbols, class_name: 'OntologyMember::Symbol'

  attr_accessible :ontology, :name, :symbols

  acts_as_vertex
  connected_by 'EEdge'

  def to_s
    name
  end
end
