require 'xml/libxml'
require 'lib/gpx/gpx' # load this and xml/libxml just to get GPX::VERSION
require 'rake'        # For FileList
Gem::Specification.new do |s|
  s.name = 'gpx'
  s.version = GPX::VERSION
  s.summary = %q{A basic API for reading and writing GPX files.}
  s.description = %q{A basic API for reading and writing GPX files.}
  s.files = FileList[ "lib/**/*", "bin/*", "tests/**/*", "[A-Z]*", "Rakefile", "doc/**/*" ]
  s.require_path = 'lib'
  s.has_rdoc = true
  s.author = "Doug Fales"
  s.email = "doug.fales@gmail.com"
  s.homepage = "http://dougfales.github.com/gpx/"
  s.rubyforge_project = "gpx"
end
