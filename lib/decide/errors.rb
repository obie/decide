# frozen_string_literal: true

module Decide
  # Raised by an asker to signal it could not answer. Any other StandardError
  # raised by an asker is also treated as a failure by Decision#decide.
  class AskFailed < StandardError
    attr_reader :code

    def initialize(message = "ask failed", code: nil)
      @code = code
      super(message)
    end
  end

  # Raised internally when an asker's response is missing one or more
  # question ids that the decision declared.
  class MissingAnswers < StandardError
    attr_reader :missing

    def initialize(missing)
      @missing = missing
      super("missing answers for: #{missing.join(', ')}")
    end
  end
end
