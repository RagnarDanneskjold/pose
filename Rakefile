#!/usr/bin/env rake

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

Bundler::GemHelper.install_tasks

# RSpec tasks.
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new :spec_sqlite do
  ENV['pose_env'] = 'sqlite'
end

RSpec::Core::RakeTask.new :spec_postgres do
  ENV['pose_env'] = 'postgres'
end

task :default => [:spec_sqlite, :spec_postgres]