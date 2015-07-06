require 'spec_helper'

describe SymbolsController do
  render_views

  context 'Ontology Instance' do
    let!(:user) { create :user }
    let!(:logic) { create :logic, user: user }
    let!(:ontology) { create :single_ontology, logic: logic }
    let!(:repository) { ontology.repository }

    context 'on GET to index' do
      before do
        get :index,
          repository_id: repository.to_param, ontology_id: ontology.to_param
      end

      it { expect(subject).to respond_with :success }
      it { expect(subject).to_not render_template(partial: '_oops_state') }
    end
  end

  context 'OWL Ontology instance' do
    let!(:user) { create :user }
    let!(:logic) { create :logic, name: 'OWL', user: user }
    let!(:ontology) { create :single_ontology, logic: logic }
    let!(:repository) { ontology.repository }

    context 'on GET to index' do
      before do
        get :index,
          repository_id: repository.to_param, ontology_id: ontology.to_param
      end

      it { expect(subject).to respond_with :success }
      it { expect(subject).to render_template(partial: '_oops_state') }
    end
  end
end
