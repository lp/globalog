require 'rubygems'
Gem::manage_gems
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
  s.name = 'globalog'
  s.version = '0.1.2'
  s.author = 'Louis-Philippe Perron'
  s.email = 'lp@spiralix.org'
  s.homepage = 'http://globalog.rubyforge.org/'
  s.rubyforge_project = 'GlobaLog'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Cascading Global Log'
  s.files = FileList["{lib,test}/**/*"].exclude("doc").to_a
  s.require_path = "lib"
  s.test_file = "test/tc_globalog_main.rb"
  s.has_rdoc = true
end
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end
