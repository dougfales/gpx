require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require File.dirname(__FILE__) + '/lib/gpx'

PKG_VERSION = GPX::VERSION
PKG_NAME = "gpx"
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"
RUBY_FORGE_PROJECT = "gpx"
RUBY_FORGE_USER = ENV['RUBY_FORGE_USER'] || "dougfales"
RELEASE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"

PKG_FILES = FileList[
    "lib/**/*", "bin/*", "tests/**/*", "[A-Z]*", "Rakefile", "doc/**/*"
]

desc "Default Task"
task :default => [ :test ]

# Run the unit tests
desc "Run all unit tests"
Rake::TestTask.new("test") { |t|
  t.libs << "lib"
  t.pattern = 'tests/*_test.rb'
  t.verbose = true
}

# Make a console, useful when working on tests
desc "Generate a test console"
task :console do
   verbose( false ) { sh "irb -I lib/ -r 'gpx'" }
end

# Genereate the RDoc documentation
desc "Create documentation"
Rake::RDocTask.new("doc") { |rdoc|
  rdoc.title = "Ruby GPX API"
  rdoc.rdoc_dir = 'html'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
}

# Genereate the package
spec = Gem::Specification.new do |s|

  s.name = 'gpx'
  s.version = PKG_VERSION
  s.summary = <<-EOF
   A basic API for reading and writing GPX files.
  EOF
  s.description = <<-EOF
   A basic API for reading and writing GPX files.
  EOF

  s.files = PKG_FILES

  s.require_path = 'lib'
  s.autorequire = 'gpx'

  s.has_rdoc = true

  s.author = "Doug Fales"
  s.email = "doug.fales@gmail.com"
  s.homepage = "http://gpx.rubyforge.com/"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

desc "Report code statistics (KLOCs, etc) from the application"
task :stats do
  require 'code_statistics'
  CodeStatistics.new(
    ["Library", "lib"],
    ["Units", "tests"]
  ).to_s
end
