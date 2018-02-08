# Task Declarations
task default: %w[test]

# Task Definitions
# Default task to run the program simply by calling 'rake'
task :run do
  ruby './lib/run_tracker.rb'
end

task :update do
  sh 'bundle update'
  sh 'bundle install'
end
