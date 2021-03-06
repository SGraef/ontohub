require 'spec_helper'

describe Api::V1::SymbolsController do
  let(:symbol) { create :symbol }
  let(:ontology) { symbol.ontology }
  let(:repository) { ontology.repository }

  context 'on GET to index' do
    context 'requesting json representation', api_specification: true do
      let(:symbols_schema) do
        schema_for_command('ontology/symbols', :get, 200)
      end

      before do
        get :index,
          repository_id: repository.to_param,
          ontology_id: ontology.to_param,
          locid: ontology.locid,
          format: :json
      end

      it { should respond_with :success }

      it 'respond with json content type' do
        expect(response.content_type.to_s).to eq('application/json')
      end

      it 'should return a representation that validates against the schema' do
        VCR.use_cassette 'api/json-schemata/ontology/symbols' do
          expect(response.body).
            to match_json_schema(symbols_schema)
        end
      end
    end
  end

  context 'on GET to show' do
    context 'requesting json representation', api_specification: true do
      let(:symbol_schema) { schema_for('symbol') }

      before do
        get :show,
          repository_id: repository.to_param,
          ontology_id: ontology.to_param,
          id: symbol.to_param,
          locid: symbol.locid,
          format: :json
      end

      it { should respond_with :success }

      it 'respond with json content type' do
        expect(response.content_type.to_s).to eq('application/json')
      end

      it 'should return a representation that validates against the schema' do
        VCR.use_cassette 'api/json-schemata/symbol' do
          expect(response.body).to match_json_schema(symbol_schema)
        end
      end
    end
  end
end
