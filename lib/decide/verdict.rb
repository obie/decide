# frozen_string_literal: true

module Decide
  # The outcome of asking a Decision about a state: whether it matched,
  # whether the asker failed (and if so whether it failed open), and the
  # answers that led to that outcome.
  class Verdict
    attr_reader :decision_name, :floor, :answers, :error

    def initialize(decision_name:, floor:, matched:, fail_open:, failed:, probability:, answers:, error: nil)
      @decision_name = decision_name
      @floor = floor
      @matched = matched
      @fail_open = fail_open
      @failed = failed
      @probability = probability
      @answers = answers
      @error = error
    end

    def matched?
      @matched
    end

    def fail_open?
      @fail_open
    end

    def failed?
      @failed
    end

    def probability
      @probability
    end

    def [](id)
      answers[id.to_sym]
    end

    def to_h
      {
        decision: decision_name,
        matched: matched?,
        fail_open: fail_open?,
        failed: failed?,
        probability: probability,
        floor: floor,
        answers: answers.transform_values { |a| a.to_h },
        error: error&.message
      }
    end
  end
end
