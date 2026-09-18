# frozen_string_literal: true

require "timeout"

module Decide
  # A named decision: a set of typed questions asked of an asker about a
  # state, reduced to a match/no-match verdict by a rule.
  class Decision
    FAIL_MODES = %i[open closed].freeze

    attr_reader :name, :asker, :floor, :fail_mode, :timeout, :questions

    def initialize(name:, asker:, floor: 0.5, fail_mode: :open, timeout: nil, &block)
      unless FAIL_MODES.include?(fail_mode)
        raise ArgumentError, "fail_mode must be :open or :closed, got #{fail_mode.inspect}"
      end

      @name = name
      @asker = asker
      @floor = floor
      @fail_mode = fail_mode
      @timeout = timeout
      @questions = {}
      @primary_noul_id = nil
      @rule = nil

      instance_eval(&block) if block

      if @rule.nil? && @primary_noul_id.nil?
        raise ArgumentError, "a decision needs a noul question or a rule"
      end
    end

    def noul(id, instructions, criteria: nil)
      @primary_noul_id ||= id.to_sym
      add_question(id, Questions.noul(instructions, criteria: criteria))
    end

    def choice(id, instructions, criteria:)
      add_question(id, Questions.choice(instructions, criteria: criteria))
    end

    def score(id, instructions, criteria:)
      add_question(id, Questions.score(instructions, criteria: criteria))
    end

    def rule(&block)
      @rule = block
    end

    def decide(state)
      answers = begin
        build_answers(call_asker(state))
      rescue StandardError => e
        return failed_verdict(e)
      end

      Verdict.new(
        decision_name: name,
        floor: floor,
        matched: evaluate_rule(answers) ? true : false,
        fail_open: false,
        failed: false,
        probability: primary_probability(answers),
        answers: answers
      )
    end

    private

    def add_question(id, question)
      @questions[id.to_s] = question
      id
    end

    def call_asker(state)
      if timeout
        Timeout.timeout(timeout) { asker.call(state: state, questions: questions) }
      else
        asker.call(state: state, questions: questions)
      end
    end

    def build_answers(raw)
      missing = questions.keys.map(&:to_sym) - raw.keys.map { |k| k.to_sym }
      raise MissingAnswers, missing unless missing.empty?

      raw.each_with_object({}) do |(id, hash), acc|
        acc[id.to_sym] = Answers.build(hash)
      end
    end

    def evaluate_rule(answers)
      if @rule
        @rule.call(answers)
      else
        answers[@primary_noul_id].noul >= floor
      end
    end

    def primary_probability(answers)
      return nil unless @primary_noul_id

      answers[@primary_noul_id]&.noul
    end

    def failed_verdict(error)
      Verdict.new(
        decision_name: name,
        floor: floor,
        matched: fail_mode == :open,
        fail_open: fail_mode == :open,
        failed: true,
        probability: nil,
        answers: {},
        error: error
      )
    end
  end
end
