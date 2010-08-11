require 'rubygems'
require 'bundler'
Bundler.setup

require 'spec/rake/spectask'

task :default => :gem

desc "Run unit tests (Rspec)"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/*_spec.rb']
  t.spec_opts = ['--options', 'spec/spec.opts']
end

CURRENT_VERSION = '0.1.0'

desc "Create Gem"
task :gem do
  Echoe.new('duck_reports', CURRENT_VERSION) do |p|
    p.description     = "Ruby versioning Gem"
    p.url             = "http://github.com/riopro/deja_vue"
    p.author          = "Riopro Informatica Ltda"
    p.email           = "riopro@riopro.com.br"
    p.ignore_pattern  = ["tmp/*", "script/*", "Gemfile", "Gemfile.lock"]
    p.development_dependencies = []
    p.runtime_dependencies = ["mongo >=1.0.7", "bson_ext >= 1.0.4", "mongo_mapper >= 0.8.2"]
  end
  Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }
end
