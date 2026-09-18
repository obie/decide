# frozen_string_literal: true

begin
  require "ruby_decision_model"
rescue LoadError
  raise LoadError, "Decide::Askers::DecisionModel requires the ruby_decision_model gem. " \
                    "Add it to your Gemfile: gem \"ruby_decision_model\""
end

module Decide
  module Askers
    # Adapts a ruby_decision_model client to the Decide asker protocol.
    class DecisionModel
      def initialize(client)
        @client = client
      end

      def call(state:, questions:)
        response = @client.ask(state: state, questions: questions)

        response.answers.each_with_object({}) do |(id, answer), acc|
          acc[id] = {
            type: safe(answer, :type),
            noul: safe(answer, :noul),
            choice: safe(answer, :choice),
            confidence: safe(answer, :confidence),
            probabilities: safe(answer, :probabilities),
            score: safe(answer, :score),
            legend: safe(answer, :legend)
          }.compact
        end
      rescue RubyDecisionModel::Error => e
        raise Decide::AskFailed, e.message
      end

      private

      def safe(answer, method)
        answer.respond_to?(method) ? answer.public_send(method) : nil
      end
    end
  end
end
