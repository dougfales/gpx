# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rdoc/task'
require 'rubocop/rake_task'

RuboCop::RakeTask.new

desc 'Default Task'
task default: %i[test rubocop]

namespace :ci do
  task :build do
    puts 'Creating tests/output directory...'
    FileUtils.mkdir_p 'tests/output'
    Rake::Task[:test].invoke
  end
end

# Run the unit tests
desc 'Run all unit tests'
Rake::TestTask.new('test') do |t|
  t.libs << 'lib'
  t.pattern = 'tests/*_test.rb'
  t.verbose = true
end

# Genereate the RDoc documentation
desc 'Create documentation'
Rake::RDocTask.new('doc') do |rdoc|
  rdoc.title = 'Ruby GPX API'
  rdoc.rdoc_dir = 'html'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
