# frozen_string_literal: true

module Decide
  # Small value objects wrapping an asker's symbol-keyed answer hash.
  module Answers
    Noul = Struct.new(:noul, :type) do
      def probability
        noul
      end
    end

    Choice = Struct.new(:choice, :confidence, :probabilities, :type)

    Score = Struct.new(:score, :confidence, :probabilities, :legend, :type)

    module_function

    def build(hash)
      hash = hash.transform_keys(&:to_sym)

      case hash[:type]
      when "noul"
        Noul.new(hash[:noul], hash[:type])
      when "choice"
        Choice.new(hash[:choice], hash[:confidence], hash[:probabilities], hash[:type])
      when "score"
        Score.new(hash[:score], hash[:confidence], hash[:probabilities], hash[:legend], hash[:type])
      else
        raise ArgumentError, "unknown answer type: #{hash[:type].inspect}"
      end
    end
  end
end
