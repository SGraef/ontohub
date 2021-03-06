require 'spec_helper'

describe RepositoriesController do
  context 'deleting a repository' do
    let(:ontology){ create :ontology }
    let(:repository){ ontology.repository }
    let(:user){ create(:permission, role: 'owner', item: repository).subject }

    context 'signed in' do
      before { sign_in user }

      context 'successful deletion' do
        before { delete :destroy, id: repository.to_param }

        it{ should respond_with :found }
        it{ response.should redirect_to Repository }
      end

      context 'unsuccessful deletion' do
        before do
          importing_repository = create :repository
          importing = create :ontology, repository: importing_repository
          create :import_mapping, target: importing, source: ontology
          delete :destroy, id: repository.to_param
        end

        it 'sets the flash' do
          expect(flash[:error]).to match(/is imported/)
        end

        it{ should respond_with :found }
        it{ response.should redirect_to repository }
      end
    end
  end

  context 'Repository instance' do
    render_views

    let!(:repository) { create :repository }

    context 'on GET to index' do
      before { get :index }

      it { should respond_with :success }
      it { should render_template :index }
      it { should render_template 'repositories/_repository' }
    end

    context 'on GET to show' do
      context 'requesting standard representation' do
        before { get :show, id: repository.path }

        it { should respond_with :success }
        it { should render_template :show }
      end

    end
  end

  context 'creating a clone', :process_jobs_synchronously do
    context 'signed in' do
      let(:user) { create :user }
      let(:git_repository) { create :git_repository }
      before do
        sign_in user
      end

      context 'mirror' do
        before do
          post :create, repository: { name: 'repo',
            source_address: "file://#{git_repository.path}",
            remote_type: 'mirror' }
        end

        after do
          FileUtils.rm_rf(git_repository.path)
        end

        it { should respond_with :found }
        it { response.should redirect_to Repository.find_by_path('repo') }
        it 'should have created a mirrored repository' do
          expect(Repository.find_by_path('repo').mirror?).to be_truthy
        end
      end

      context 'fork' do
        before do
          post :create, repository: { name: 'repo',
            source_address: "file://#{git_repository.path}",
            remote_type: 'fork' }
        end

        it { should respond_with :found }
        it { response.should redirect_to Repository.find_by_path('repo') }
        it 'should have created a non-mirrored repository' do
          expect(Repository.find_by_path('repo').mirror?).to be_falsy
        end
      end
    end
  end
end
