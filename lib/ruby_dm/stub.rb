# frozen_string_literal: true

module RubyDM
  # A test asker. Coerces simple Ruby values into answer hashes, or accepts
  # explicit answer hashes, keyed by question id.
  class Stub
    attr_reader :calls

    def initialize(raise: nil, **answers)
      @raise = raise
      @answers = answers
      @calls = []
    end

    def call(state:, questions:)
      @calls << { state: state, questions: questions }

      raise @raise if @raise

      questions.each_key.with_object({}) do |id, acc|
        key = id.to_sym
        value = @answers.fetch(key) do
          raise ArgumentError, "RubyDM::Stub has no answer for #{id.inspect}"
        end
        acc[id] = coerce(value)
      end
    end

    private

    def coerce(value)
      case value
      when Hash
        value
      when Float
        { type: "noul", noul: value }
      when String
        { type: "choice", choice: value, confidence: 1.0, probabilities: { value => 1.0 } }
      when Integer
        { type: "score", score: value, confidence: 1.0, probabilities: {}, legend: {} }
      else
        raise ArgumentError, "RubyDM::Stub cannot coerce #{value.class}"
      end
    end
  end
end
