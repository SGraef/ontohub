require 'spec_helper'

describe RepositoryPullingWorker do
  subject! { create :repository_with_empty_remote }
  before { RepositoryFetchingWorker.clear }

  shared_examples 'perform' do |state, minutes, created_jobs_count|
    context("state #{state}, imported " +
            (minutes ? "#{minutes} minutes ago" : 'never before')) do
      before do
        subject.update_attributes!(
          {state: state.to_s,
           imported_at: (minutes ? minutes.minutes.ago : nil)},
           without_protection: true,
        )
        RepositoryPullingWorker.new.perform
      end
      it("should create #{created_jobs_count} jobs") do
        expect(RepositoryFetchingWorker.jobs.count).to eq(created_jobs_count)
      end
    end
  end

  include_examples 'perform', :processing, nil, 0
  include_examples 'perform', :processing,  20, 0
  include_examples 'perform', :done,       nil, 1
  include_examples 'perform', :done,        10, 0
  include_examples 'perform', :done,        20, 1
  include_examples 'perform', :failed,     nil, 0
  include_examples 'perform', :failed,      20, 0
end
