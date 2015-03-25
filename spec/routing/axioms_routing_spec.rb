require 'spec_helper'

describe AxiomsController do
  it do
    should route(:get, "/repositories/path/ontologies/id/axioms").to(
      controller: :axioms,
      action: :index,
      repository_id: 'path',
      ontology_id: 'id')
  end
end
