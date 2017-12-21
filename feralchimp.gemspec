$:.unshift(File.expand_path("../lib", __FILE__))
require "feralchimp/version"

Gem::Specification.new do |spec|
  spec.summary = "A simple API wrapper for Mailchimp."
  spec.add_development_dependency("guard-rspec")
  spec.add_development_dependency("coveralls")
  spec.add_development_dependency("webmock")
  spec.email = ["envygeeks@gmail.com"]
  spec.version = Feralchimp::VERSION
  spec.name = "feralchimp"
  spec.license = "MIT"
  spec.has_rdoc = false
  spec.require_paths = ["lib"]
  spec.authors = ["Jordon Bedwell"]
  spec.add_development_dependency("rake")
  spec.add_development_dependency("rspec")
  spec.add_development_dependency("simplecov")
  spec.add_runtime_dependency("json", "~> 1.8")
  spec.add_runtime_dependency("faraday", "~> 0.8.0")
  spec.add_development_dependency("luna-rspec-formatters")
  spec.homepage = "http://github.com/envygeeks/feralchimp/"
  spec.files = %W(Rakefile Gemfile Readme.md License) + Dir["lib/**/*"]
  spec.description = "A simple API wrapper for Mailchimp that uses Faraday."
end
