# frozen_string_literal: true

require "test_helper"

class StubTest < Minitest::Test
  def test_coerces_float_to_noul
    stub = RubyDM::Stub.new(matches: 0.7)
    result = stub.call(state: {}, questions: { "matches" => {} })
    assert_equal({ type: "noul", noul: 0.7 }, result["matches"])
  end

  def test_coerces_string_to_choice
    stub = RubyDM::Stub.new(team: "payments")
    result = stub.call(state: {}, questions: { "team" => {} })
    assert_equal(
      { type: "choice", choice: "payments", confidence: 1.0, probabilities: { "payments" => 1.0 } },
      result["team"]
    )
  end

  def test_coerces_integer_to_score
    stub = RubyDM::Stub.new(severity: 3)
    result = stub.call(state: {}, questions: { "severity" => {} })
    assert_equal(
      { type: "score", score: 3, confidence: 1.0, probabilities: {}, legend: {} },
      result["severity"]
    )
  end

  def test_accepts_explicit_hash
    stub = RubyDM::Stub.new(matches: { type: "noul", noul: 0.42 })
    result = stub.call(state: {}, questions: { "matches" => {} })
    assert_equal({ type: "noul", noul: 0.42 }, result["matches"])
  end

  def test_raises_configured_error
    stub = RubyDM::Stub.new(raise: RuntimeError.new("boom"))
    assert_raises(RuntimeError) { stub.call(state: {}, questions: { "matches" => {} }) }
  end

  def test_records_calls
    stub = RubyDM::Stub.new(matches: 0.5)
    stub.call(state: { "a" => 1 }, questions: { "matches" => {} })
    assert_equal 1, stub.calls.size
    assert_equal({ "a" => 1 }, stub.calls.first[:state])
  end
end
