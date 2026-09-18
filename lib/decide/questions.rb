# frozen_string_literal: true

module Decide
  # Builds wire-compatible question hashes (string keys) for the three
  # question types a decision model understands: noul, choice, score.
  module Questions
    module_function

    def noul(instructions, criteria: nil)
      validate_instructions!(instructions)

      question = { "type" => "noul", "instructions" => instructions }

      unless criteria.nil?
        keys = criteria.keys.map(&:to_sym)
        unless keys.include?(:true) && keys.include?(:false)
          raise ArgumentError, "noul criteria must have both true and false keys"
        end

        question["criteria"] = {
          "true" => criteria[:true] || criteria["true"],
          "false" => criteria[:false] || criteria["false"]
        }
      end

      question
    end

    def choice(instructions, criteria:)
      validate_instructions!(instructions)

      unless criteria.is_a?(Hash) && criteria.size.between?(1, 255)
        raise ArgumentError, "choice criteria must be a Hash with 1..255 entries"
      end

      {
        "type" => "choice",
        "instructions" => instructions,
        "criteria" => criteria.transform_keys(&:to_s)
      }
    end

    def score(instructions, criteria:)
      validate_instructions!(instructions)

      unless criteria.is_a?(Array) && criteria.size.between?(2, 10)
        raise ArgumentError, "score criteria must be an Array with 2..10 entries"
      end

      {
        "type" => "score",
        "instructions" => instructions,
        "criteria" => criteria
      }
    end

    def validate_instructions!(instructions)
      valid = case instructions
              when String then !instructions.empty?
              when Hash, Array then true
              else false
              end

      raise ArgumentError, "instructions must be a non-empty String, Hash, or Array" unless valid
    end
    private_class_method :validate_instructions!
  end
end
