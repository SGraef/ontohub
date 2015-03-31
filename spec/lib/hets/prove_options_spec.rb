require 'spec_helper'

describe Hets::ProveOptions do
  let(:prover) { create :prover }
  let(:theorem) { create :theorem }
  let(:ontology) { theorem.ontology }
  let(:axiom) { create :axiom, ontology: ontology }
  let(:parent_ontology) { ontology.parent }

  context 'with strings' do
    let(:options) { {node: ontology.name,
                     prover: prover.name,
                     axioms: [axiom.name],
                     theorems: [theorem.name],
                     timeout: '10'} }
    let(:prove_options) { Hets::ProveOptions.new(options) }

    it 'does not change the options' do
      expect(prove_options.options).to eq(options)
    end
  end

  context 'with general objects' do
    let(:options) { {ontology: ontology,
                     prover: prover,
                     axioms: [axiom],
                     theorems: [theorem],
                     timeout: 10} }
    let!(:axiom_names) { options[:axioms].map(&:name) }
    let!(:theorem_names) { options[:theorems].map(&:name) }
    let(:prove_options) { Hets::ProveOptions.new(options) }

    it "removes the key 'ontology'" do
      expect(prove_options.options.has_key?(:ontology)).to be(false)
    end

    it 'sets :node to the ontology name' do
      expect(prove_options.options[:node]).to eq(ontology.name)
    end

    it 'sets :prover to the prover name' do
      expect(prove_options.options[:prover]).to eq(prover.name)
    end

    it 'sets :axioms to the axioms names' do
      expect(prove_options.options[:axioms]).to eq(axiom_names)
    end

    it 'sets :theorems to the theorems names' do
      expect(prove_options.options[:theorems]).to eq(theorem_names)
    end

    it 'sets the timeout as a string' do
      expect(prove_options.options[:timeout]).to eq('10')
    end
  end

  context 'using the parent ontology' do
    let(:options) { {ontology: parent_ontology} }
    let(:prove_options) { Hets::ProveOptions.new(options) }

    it 'it does not set :node' do
      expect(prove_options.options.has_key?(:node)).to be(false)
    end

    it "removes the key 'ontology'" do
      expect(prove_options.options.has_key?(:ontology)).to be(false)
    end
  end
end
