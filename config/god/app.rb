require File.expand_path('../sidekiq_workers',  __FILE__)
require File.expand_path('../hets_workers',  __FILE__)
require File.expand_path('../../../lib/environment_light_with_hets.rb')

RAILS_ROOT = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'

# High load workers (except hets) are: sequential and priority_push.
HIGH_LOAD_WORKERS_COUNT = 2

God.pid_file_directory = File.join(RAILS_ROOT, 'tmp/pids/')

SidekiqWorkers.configure do
  if ENV['RAILS_ENV']=='production'
    # one worker per core
    Settings.hets.instances_count.times.each do
      watch 'hets', 1
    end

    # one worker for the default queue
    watch 'default', 5

    # one worker for the sequential queue
    watch 'sequential', 1

    watch 'priority_push', 1
  else
    # one worker for all queues
    watch %w(hets default sequential priority_push), 1
  end
end

HetsWorkers.configure do
  watch
end
