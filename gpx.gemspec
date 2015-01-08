# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gpx/version'

Gem::Specification.new do |s|
  s.name = 'andrewhao-gpx'
  s.version = GPX::VERSION
  s.authors = ["Guillaume Dott", "Doug Fales", "Andrew Hao"]
  s.email = ["guillaume+github@dott.fr", "doug.fales@gmail.com", "andrewhao@gmail.com"]
  s.summary = %q{A basic API for reading and writing GPX files.}
  s.description = %q{A basic API for reading and writing GPX files.}

  s.files = `git ls-files`.split($/)
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]
  s.has_rdoc = true

  s.homepage = "http://www.github.com/andrewhao/gpx"
  s.add_dependency 'rake'
  s.add_dependency 'nokogiri'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'minitest'
end
