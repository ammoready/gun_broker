require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'

task :default => :spec

desc 'Run the specs'
RSpec::Core::RakeTask.new(:spec)

desc 'Generate API docs'
YARD::Rake::YardocTask.new(:docs) do |t|
  t.files = ['lib/**/*.rb']
end

namespace :docs do
  desc 'Run the docs server'
  task :server do
    $stdout.puts `yard server --reload --bind 0.0.0.0`
  end
end
