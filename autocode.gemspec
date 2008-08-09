Gem::Specification.new do |s|
  s.name = %q{autocode}
  s.version = "1.0.0"

  s.specification_version = 2 if s.respond_to? :specification_version=

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dan Yoder", "Matthew King", "Lawrence Pitt"]
  s.date = %q{2008-06-09}
  s.email = %q{dan@zeraweb.com}
  s.files = ["lib/autocode.rb", "test/auto_create.rb", "test/auto_eval.rb", "test/auto_load.rb", "test/helpers.rb", "test/normalize.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://dev.zeraweb.com/}
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.6")
  s.rubyforge_project = %q{autocode}
  s.rubygems_version = %q{1.0.1}
  s.summary = %q{Utility for auto-including, reloading, and generating classes and modules.}
end
