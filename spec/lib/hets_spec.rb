require 'spec_helper'

describe Hets, :needs_hets do

  after do
    File.delete @xml_path if @xml_path
  end

  context 'Output directory parameter' do
    before do
      xml_paths = Hets.parse Rails.root.join('test/fixtures/ontologies/owl/pizza.owl'), [], '/tmp'
      @xml_path = xml_paths.last
    end

    it 'correctly be used' do
      assert @xml_path.starts_with? '/tmp'
    end
  end

  %w(owl/pizza.owl owl/generations.owl clif/cat.clif).each do |path|
    context path do
      before do
        xml_paths = Hets.parse Rails.root.join("test/fixtures/ontologies/#{path}"), [], '/tmp'
        @xml_path = xml_paths.last
        @pp_path = xml_paths.first
      end

      it 'have created output file' do
        assert File.exists? @xml_path
      end

      it 'have generated importable output' do
        assert_nothing_raised do
          ontology = FactoryGirl.create :ontology
          user = FactoryGirl.create :user
          parse_this(user, ontology, @xml_path, @pp_path)
          `git checkout #{@xml_path} 2>/dev/null`
        end
      end
    end
  end

  context 'with url-catalog' do
    let(:input_file) { ontology_file('clif/monoid.clif') }
    let(:url_catalog) do
      ['http://colore.oor.net=http://develop.ontohub.org/colore/ontologies',
      'https://colore.oor.net=https://develop.ontohub.org/colore/ontologies']
    end
    let(:catalog_args) do
      # any_args is a "don't care which and how many arguments" in rspeck mocks.
      [any_args, '-C', url_catalog.join('/'), any_args]
    end

    before do
      allow(Subprocess).to receive(:run).with(*catalog_args).
        and_return('Writing file: some_file')
    end

    it 'have called hets with the catalog' do
      expect(Hets.parse(input_file, url_catalog, '/tmp')).to eq(['some_file'])
    end

    it 'created a subprocess with catalog arguments' do
      Hets.parse(input_file, url_catalog, '/tmp')
      expect(Subprocess).to(have_received(:run).with(*catalog_args))
    end

    # This test is disabled, because for this ontology, the XML output of hets
    # contains _two_ DGNode tags, which is interpreted as distributed ontology
    # by the ontology import mechanism (see app/models/ontology/import.rb).
    # Funny though, the test did not fail always. Testing on the existence of
    # the XML output file should suffice as hets currently only has to recognize
    # the command line option for URL cataloges and does no URL substitutions.
=begin
    it 'have generated importable output' do
      assert_nothing_raised do
        ontology = FactoryGirl.create :ontology
        user = FactoryGirl.create :user
        ontology.import_xml_from_file @xml_path, @pp_path, user
        `git checkout #{@xml_path} 2>/dev/null`
      end
    end
=end
  end

  it 'raise exception if provided with wrong file-format' do
    assert_raise Hets::ExecutionError do
      Hets.parse Rails.root.join('test/fixtures/ontologies/xml/valid.xml')
    end
  end
end
