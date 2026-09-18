# frozen_string_literal: true

require_relative "lib/decide/version"

Gem::Specification.new do |spec|
  spec.name        = "decide"
  spec.version     = Decide::VERSION
  spec.authors     = ["Obie Fernandez"]
  spec.email       = ["obiefernandez@gmail.com"]

  spec.summary     = "Decision maker for Ruby: turn decision model answers into policy verdicts"
  spec.description = "decide composes typed questions, match floors, and fail modes into named " \
                      "decisions. Ask a decision about a state and get a verdict that knows " \
                      "whether it matched, whether it failed open, and why. Works with any " \
                      "answer source; the ruby_decision_model gem (Typesafe Jev via OpenRouter) " \
                      "is the first."
  spec.homepage    = "https://github.com/obie/decide"
  spec.license     = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir["lib/**/*.rb"] + ["README.md", "CHANGELOG.md", "LICENSE.txt"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "minitest", "~> 6.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
