require 'rubygems'
require 'rubygems/specification'
require 'bundler'

Bundler.setup

require 'rake'
require 'spec/rake/spectask'

desc "Run unit tests (Rspec)"

Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ['--options', 'spec/spec.opts']
end


