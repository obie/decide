# frozen_string_literal: true

# Minimal stand-in for the real ruby_decision_model gem, used only so that
# lib/decide/askers/decision_model.rb's `require "ruby_decision_model"` can
# succeed in tests without depending on the real gem at runtime.
module RubyDecisionModel
  class Error < StandardError; end
end
