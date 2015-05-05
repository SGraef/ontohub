require 'spec_helper'

describe LanguageMappingsController do
  let!(:user) { create :user }
  let!(:target_language) { create :language, user: user }
  let!(:source_language) { create :language, user: user }
  let!(:mapping) do
    create :language_mapping,
    source: source_language, target: target_language, user: user
  end

  context 'signed in as owner' do
    before { sign_in user }

    context 'on get to show' do
      before { get :show, id: mapping.id, language_id: source_language.id }
      it { should respond_with :success }
      it { should render_template :show }
      it { should_not set_the_flash }
    end

    context 'on get to new' do
      before { get :new, language_id: source_language.id }

      it { should respond_with :success }
      it { should render_template :new }
    end

    context 'on POST to CREATE' do
      before do
        post :create, language_id: source_language.id,
          language_mapping: {source_id: source_language.id,
            target_id: target_language.id,
            iri: 'http://test.de'
          }
      end

      context 'create the record' do
        let!(:mapping_from_db) { LanguageMapping.find_by_iri('http://test.de') }

        it 'should exist' do
          expect(mapping_from_db).not_to be(nil)
        end

        it 'should have correct source' do
          expect(mapping_from_db.source).to eq(source_language)
        end

        it 'should have correct target' do
          expect(mapping_from_db.target).to eq(target_language)
        end
      end
    end

    context 'on PUT to Update' do
      before do
        put :update, language_id: source_language.id, id: mapping.id,
          language_mapping: {
            source_id: source_language.id,
            target_id: target_language.id,
            iri: 'http://test2.de'
          }
      end

      context 'change the record' do
        let!(:mapping_from_db) { LanguageMapping.find_by_iri('http://test2.de') }

        it 'should exist' do
          expect(mapping_from_db).not_to be(nil)
        end

        it 'should have correct source' do
          expect(mapping_from_db.source).to eq(source_language)
        end

        it 'should have correct target' do
          expect(mapping_from_db.target).to eq(target_language)
        end
      end
    end

    context 'on POST to DELETE' do
      before { delete :destroy, id: mapping.id, language_id: source_language.id }

      it 'remove the record' do
        expect(LanguageMapping.find_by_id(mapping.id)).to be(nil)
      end
    end

    context 'on GET to EDIT' do
      before { get :edit, id: mapping.id, language_id: source_language.id }
      it { should respond_with :success }
      it { should render_template :edit }
      it { should_not set_the_flash }
    end
  end



  context 'signed in as not-owner' do
    let!(:user2) { create :user }
    before { sign_in user2 }

    context 'on get to show' do
      before { get :show, id: mapping.id, language_id: source_language.id }
      it { should respond_with :success }
      it { should render_template :show }
      it { should_not set_the_flash }
    end

    context 'on get to new' do
      before { get :new, language_id: source_language.id }

      it { should respond_with :success }
      it { should render_template :new }
    end

    context 'on POST to CREATE' do
      before do
        post :create, language_id: source_language.id,
          language_mapping: {
            source_id: source_language.id,
            target_id: target_language.id,
            iri: 'http://test.de'
          }
      end

      context 'create the record' do
        let!(:mapping_from_db) { LanguageMapping.find_by_iri('http://test.de') }

        it 'should exist' do
          expect(mapping_from_db).not_to be(nil)
        end

        it 'should have correct source' do
          expect(mapping_from_db.source).to eq(source_language)
        end

        it 'should have correct target' do
          expect(mapping_from_db.target).to eq(target_language)
        end
      end
    end

    context 'on PUT to Update' do
      before do
        put :update, language_id: source_language.id, id: mapping.id,
          language_mapping: {
            source_id: source_language.id,
            target_id: target_language.id,
            iri: 'http://test2.de'
          }
      end

      it 'not change the record' do
        expect(LanguageMapping.find_by_iri('http://test2.de')).to be(nil)
      end
    end

    context 'on POST to DELETE' do
      before { delete :destroy, id: mapping.id, language_id: source_language.id }

      it 'not remove the record' do
        expect(LanguageMapping.find_by_id(mapping.id)).to eq(mapping)
      end
    end

    context 'on GET to EDIT' do
      before { get :edit, id: mapping.id, language_id: source_language.id }
      it { should respond_with :redirect }
      it { should set_the_flash.to(/not authorized/i) }
    end
  end

  context 'not signed in' do
    context 'on get to show' do
      before { get :show, id: mapping.id, language_id: source_language.id }
      it { should respond_with :success }
      it { should render_template :show }
      it { should_not set_the_flash }
    end

    context 'on get to new' do
      before { get :new, language_id: source_language.id }

      it { should respond_with :redirect }
      it { should set_the_flash }
    end
  end

  context 'on POST to CREATE' do
    before do
      post :create, language_id: source_language.id,
        language_mapping: {
          source_id: source_language.id,
          target_id: target_language.id,
          iri: 'http://test.de'
        }
    end

    it 'not create the record' do
      expect(LanguageMapping.find_by_iri('http://test.de')).to be(nil)
    end
  end

  context 'on PUT to Update' do
    before do
      put :update, language_id: source_language.id, id: mapping.id,
        language_mapping: {
          source_id: source_language.id,
          target_id: target_language.id,
          iri: 'http://test2.de'
        }
    end

    it 'not change the record' do
      expect(LanguageMapping.find_by_iri('http://test2.de')).to be(nil)
    end
  end

  context 'on POST to DELETE' do
    before { delete :destroy, id: mapping.id, language_id: source_language.id }

    it 'not remove the record' do
      expect(LanguageMapping.find_by_id(mapping.id)).to eq(mapping)
    end
  end
end
