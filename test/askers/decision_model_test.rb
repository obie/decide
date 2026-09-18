# frozen_string_literal: true

require "test_helper"

FakeAnswer = Struct.new(:type, :noul, :choice, :confidence, :probabilities, :score, :legend, keyword_init: true)
FakeResponse = Struct.new(:answers, keyword_init: true)

class FakeDecisionModelClient
  def initialize(response: nil, error: nil)
    @response = response
    @error = error
  end

  def ask(state:, questions:)
    raise @error if @error

    @response
  end
end

require "ruby_dm/askers/decision_model"

class DecisionModelAskerTest < Minitest::Test
  def test_maps_successful_response_into_symbol_keyed_hashes
    answer = FakeAnswer.new(type: "noul", noul: 0.8, confidence: nil, probabilities: nil)
    response = FakeResponse.new(answers: { "matches" => answer })
    client = FakeDecisionModelClient.new(response: response)

    result = RubyDM::Askers::DecisionModel.new(client).call(state: {}, questions: {})

    assert_equal({ type: "noul", noul: 0.8 }, result["matches"])
  end

  def test_reraises_client_errors_as_ask_failed
    client = FakeDecisionModelClient.new(error: RubyDecisionModel::Error.new("upstream failure"))

    assert_raises(RubyDM::AskFailed) do
      RubyDM::Askers::DecisionModel.new(client).call(state: {}, questions: {})
    end
  end
end
