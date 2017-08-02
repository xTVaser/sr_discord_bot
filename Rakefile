# Task Declarations
task default: %w[test]

# Task Definitions
# Default task to run the program simply by calling 'rake'
task :run do
  ruby './lib/run_tracker.rb'
end

task :format do
  sh 'rubocop -a -f simple --except Metrics'
end

task :update do
  sh 'bundle update'
  sh 'bundle install'
end

# TODO: - Can add back in Travis support if it doesnt autorun task :run
task :test do
  puts 'good idea'
end
