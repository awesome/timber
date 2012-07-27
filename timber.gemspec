$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "timber/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "timber"
  s.version     = Timber::VERSION
  s.authors     = ["Cory Schires"]
  s.email       = ["coryschires@gmail.com"]
  s.homepage    = "https://github.com/scholastica/timber"
  s.summary     = "Timber helps you create flexible, unobtrusive activity logs using rails notifications."
  s.description = %{
    Timber helps you create flexible, unobtrusive activity logs using rails notifications. Timber is best for
    making the type of logs you normally see on an administrative dashboard.
  }
  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.3"

  s.add_development_dependency "pry"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
end
