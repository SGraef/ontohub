namespace :import do
  namespace :xml_files do
    desc 'Import the latest XML of every ontology again.'
    task :again => :environment do
      ActiveRecord::Base.logger = Logger.new($stdout)
      Ontology.all.map(&:import_latest_version)
    end
  end

  namespace :hets do
    desc 'Import the hets library.'
    task :lib => :environment do
      user   = User.find_by_email! ENV['EMAIL'] unless ENV['EMAIL'].nil?
      user ||= User.find_all_by_admin(true).first

      repo = Repository.new(name: 'Hets lib')
      
      begin
        repo.save!
      rescue ActiveRecord::RecordInvalid
        abort '"Hets lib" repository already existing.'
      end

      repo.import_ontologies(user, Hets.config.library_path)
    end
  end

  desc 'Import logic graph.'
  task :logicgraph => :environment do
    def save(symbol)
      symbol.user = @user if symbol.has_attribute? "user_id"
      begin
        symbol.save!
      rescue ActiveRecord::RecordInvalid => e
        puts "Validation-Error: #{e.record} (#{e.message})"
      end
    end

    @user = User.find_all_by_admin(true).first
    @user = User.find_by_email! ENV['EMAIL'] unless ENV['EMAIL'].nil?

    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        system('hets', '-G')
        LogicgraphParser.parse(File.open(File.join(dir, 'LogicGraph.xml')),
          logic:          Proc.new{ |h| save(h) },
          language:       Proc.new{ |h| save(h) },
          logic_mapping:  Proc.new{ |h| save(h) },
          support:        Proc.new{ |h| save(h) })
        end
    end
  end

  desc 'Import keywords starting with P.'
  task :keywords => :environment do
    ontologySearch = OntologySearch.new()
    puts ontologySearch.makeKeywordListJson('P')
  end

end
