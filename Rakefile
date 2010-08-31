begin
  # Rspec 1.3.0
  require 'spec/rake/spectask'
  desc 'Default: run specs'
  task :default => :spec
  Spec::Rake::SpecTask.new do |t|
    t.spec_files = FileList["spec/**/*_spec.rb"]
  end

  Spec::Rake::SpecTask.new('rcov') do |t|
    t.spec_files = FileList["spec/**/*_spec.rb"]
    t.rcov = true
    t.rcov_opts = ['--exclude', 'spec']
  end

rescue LoadError
  puts "Rspec not available. Install it with: gem install rspec"  
end

begin
  require 'jeweler'
  require 'deja_vue/version'

  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "deja_vue"
    gemspec.version = DejaVue::VERSION
    gemspec.summary = "Do you DejaVue?"
    gemspec.description = "Keep track of your models changing history, using mongoDB as backend."
    gemspec.email = "riopro@riopro.com.br"
    gemspec.homepage = "http://github.com/riopro/deja_vue"
    gemspec.authors = ["Riopro Informática Ltda"]
    gemspec.files =  FileList["[A-Z]*", "{lib,spec,rails}/**/*"] - FileList["**/*.log"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end
