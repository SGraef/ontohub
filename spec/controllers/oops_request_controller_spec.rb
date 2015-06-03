require 'spec_helper'

describe OopsRequestsController do
  context 'OntologyVersion OOPS-Integration' do
    let!(:version) { create :ontology_version_with_file }
    let!(:ontology) { version.ontology }
    let!(:repository) { ontology.repository }

    context 'on GET to oops' do
      before do
        request.env['HTTP_REFERER'] = 'http://test.com/'
        OopsRequest.any_instance.stubs(:run)
      end

      context 'test with OOPS!' do
        before do
          post :create,
            repository_id: repository.to_param,
            ontology_id: ontology.to_param,
            ontology_version_id: version.number,
            format: :json
        end

        it { should respond_with :created }
      end

      context 'send second request' do
        context 'while pending, processing or done' do
          before do
            create :oops_request,
              state: :pending, ontology_version: version
            post :create,
              repository_id: repository.to_param,
              ontology_id: ontology.to_param,
              ontology_version_id: version.number,
              format: :json
          end

          it { should respond_with :forbidden }
        end

        context 'when failed' do
          before do
            create :oops_request,
              ontology_version: version, state: :failed
            post :create,
              repository_id: repository.to_param,
              ontology_id: ontology.to_param,
              ontology_version_id: version.number,
              format: :json
          end

          it { should respond_with :created }
        end
      end

      context 'on GET to SHOW' do
        context 'with OopsRequest' do
          before do
            create :oops_request,
              ontology_version: version,
              state: :pending
            get :show,
              repository_id: repository.to_param,
              ontology_id: ontology.to_param,
              ontology_version_id: version.number,
              format: :json
          end

          it { should respond_with :success }
        end

        context 'without OopsRequest' do
          it 'raise not found' do
            expect do
              get :show,
                repository_id: repository.to_param,
                ontology_id: ontology.to_param,
                ontology_version_id: version.number,
                format: :json
            end.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end
  end
end
