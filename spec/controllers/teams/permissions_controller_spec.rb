require 'spec_helper'

describe Teams::PermissionsController do
  let!(:team) { create :team }
  let!(:permission) { create :permission, subject: team }

  context 'on GET to index' do
    context 'not signed in' do
      before { get :index, team_id: team.to_param }

      it { should set_the_flash.to(/not authorized/) }
      it { should respond_with :redirect }
    end

    context 'signed in as normal user' do
      render_views

      before do
        sign_in create :user
        get :index, team_id: team.to_param
      end

      it { should respond_with :success }
      it { should render_template :index }
      it { should render_template 'teams/permissions/_permission' }
    end
  end
end