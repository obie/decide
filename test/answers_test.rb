# frozen_string_literal: true

require "test_helper"

class AnswersTest < Minitest::Test
  def test_builds_noul
    answer = Decide::Answers.build(type: "noul", noul: 0.8)
    assert_equal 0.8, answer.noul
    assert_equal 0.8, answer.probability
  end

  def test_builds_choice
    answer = Decide::Answers.build(type: "choice", choice: "payments", confidence: 0.9, probabilities: { "payments" => 0.9 })
    assert_equal "payments", answer.choice
    assert_equal 0.9, answer.confidence
  end

  def test_builds_score
    answer = Decide::Answers.build(type: "score", score: 3.0, confidence: 0.7, probabilities: {}, legend: {})
    assert_equal 3.0, answer.score
  end

  def test_unknown_type_raises
    assert_raises(ArgumentError) { Decide::Answers.build(type: "mystery") }
  end
end
