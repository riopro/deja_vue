# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'deja_vue/version'

Gem::Specification.new do |s|
  s.name = %q{deja_vue}
  s.version = DejaVue::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Riopro Informatica Ltda"]
  s.date = %q{2010-08-11}
  s.description = %q{DejaVue -> Ruby versioning Gem using MongoDB as backend}
  s.email = %q{riopro@riopro.com.br}
  s.extra_rdoc_files = ["README.rdoc", "lib/deja_vue.rb"]
  s.files = ["Manifest", "README.rdoc", "Rakefile", "deja_vue.gemspec", "lib/deja_vue.rb", "lib/deja_vue/has_deja_vue.rb", "lib/deja_vue/history.rb", "rails/init.rb"]
  s.homepage = %q{http://github.com/riopro/deja_vue}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "deja_vue", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{deja_vue}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Keep track of your models changing history, using MongoDB as backend}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3
  end
end
