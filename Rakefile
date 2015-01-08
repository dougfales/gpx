require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rdoc/task'

desc "Default Task"
task :default => [ :test ]

namespace :ci do
  task :build do
    puts "Creating tests/output directory..."
    FileUtils.mkdir_p "tests/output"
    Rake::Task[:test].invoke
  end
end

# Run the unit tests
desc "Run all unit tests"
Rake::TestTask.new("test") { |t|
  t.libs << "lib"
  t.pattern = 'tests/*_test.rb'
  t.verbose = true
}

# Genereate the RDoc documentation
desc "Create documentation"
Rake::RDocTask.new("doc") { |rdoc|
  rdoc.title = "Ruby GPX API"
  rdoc.rdoc_dir = 'html'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
}
