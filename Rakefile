require "bundler/gem_tasks"
require "rspec/core/rake_task"

# Task Declarations
task :default => %w[run]
task :test => :spec

# Task Definitions
# Default task to run the program simply by calling 'rake'
task :run do
  ruby "./lib/sr_discord_bot.rb"
end


RSpec::Core::RakeTask.new(:spec)
