Given(/^there is a distributed ontology$/) do
  @distributed_ontology = FactoryGirl.create :distributed_ontology, :with_versioned_children
  @ontology = @distributed_ontology
end

When(/^i visit the versions tab of a child ontology$/) do
  @ontology = @distributed_ontology.children.first

  visit repository_ontology_ontology_versions_path(@ontology.repository, @ontology)
end

Then(/^i should see the corresponding versions$/) do
  id = @ontology.versions.first.id
  selector = %(.evaluation-state[data-id="#{id}"][data-klass="OntologyVersion"])
  expect(page).to have_css(selector)
end
