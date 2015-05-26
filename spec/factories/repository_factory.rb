FactoryGirl.define do
  factory :repository do
    sequence(:name) { |n| "Repository #{n}" }
    description { Faker::Lorem.paragraph }

    factory :repository_with_commits do |repository|
      repository.after(:create) do |repository|

        root_path = File.expand_path('../../../', __FILE__)
        fixture_path = File.join(root_path, 'spec/fixtures/ontologies/clif/')

        git_repository = repository.git
        userinfo = {
          email: 'janjansson.com',
          name: 'Jan Jansson',
          time: Time.now
        }
        filepath1 = 'cat.clif'
        filepath2 = 'Px.clif'
        message = 'Some commit message'
        commit_add1 = repository.save_file_only(File.join(fixture_path, 'cat1.clif'), filepath1, message, create(:user))
        sleep 1
        commit_add2 = repository.save_file_only(File.join(fixture_path, filepath2), filepath2, message, create(:user))
        sleep 1
        commit_add3 = repository.save_file_only(File.join(fixture_path, 'cat2.clif'), filepath1, message, create(:user))
      end
    end

    factory :repository_with_remote do |repository|
      repository.after(:build) do |repository|

        root_path = File.expand_path('../../../', __FILE__)
        fixture_path = File.join(root_path, 'spec/fixtures/ontologies/clif/')

        path = File.join(Ontohub::Application.config.git_root, 'repository')
        git_repository = GitRepository.new(path)
        userinfo = {
          email: 'janjansson.com',
          name: 'Jan Jansson',
          time: Time.now
        }
        filepath1 = 'cat.clif'
        filepath2 = 'Px.clif'
        message = 'Some commit message'
        commit_add1 = git_repository.commit_file(userinfo, File.read(File.join(fixture_path, 'cat1.clif')), filepath1, message)
        commit_add2 = git_repository.commit_file(userinfo, File.read(File.join(fixture_path, filepath2)), filepath2, message)
        commit_add3 = git_repository.commit_file(userinfo, File.read(File.join(fixture_path, 'cat2.clif')), filepath1, message)

        repository.remote_type ||= 'mirror'
        repository.source_type = 'git'
        repository.source_address = path
      end
    end

    factory :repository_with_empty_remote do |repository|
      repository.after(:build) do |repository|
        path = File.join(Ontohub::Application.config.git_root, 'repository')
        git_repository = GitRepository.new(path)
        repository.remote_type ||= 'mirror'
        repository.source_type = 'git'
        repository.source_address = path
      end
    end

    factory :repository_git_mirror do
      remote_type { 'mirror' }
      source_type { 'git' }
    end
  end
end
