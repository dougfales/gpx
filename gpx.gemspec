# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gpx/version'

Gem::Specification.new do |s|
  s.name = 'gpx'
  s.version = GPX::VERSION
  s.authors = ['Guillaume Dott', 'Doug Fales', 'Andrew Hao']
  s.email = ['guillaume+github@dott.fr', 'doug.fales@gmail.com', 'andrewhao@gmail.com']
  s.summary = 'A basic API for reading and writing GPX files.'
  s.description = 'A basic API for reading and writing GPX files.'

  s.required_ruby_version = '~>2.3'

  s.files = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']
  s.has_rdoc = true

  s.homepage = 'http://www.github.com/dougfales/gpx'
  s.add_dependency 'nokogiri', '~>1.7'
  s.add_dependency 'rake'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'rubocop'
end
