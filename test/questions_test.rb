# frozen_string_literal: true

require "test_helper"

class QuestionsTest < Minitest::Test
  def test_noul_without_criteria
    q = RubyDM::Questions.noul("does it match?")
    assert_equal({ "type" => "noul", "instructions" => "does it match?" }, q)
  end

  def test_noul_with_criteria
    q = RubyDM::Questions.noul("x?", criteria: { true: "yes", false: "no" })
    assert_equal({ "true" => "yes", "false" => "no" }, q["criteria"])
  end

  def test_noul_criteria_requires_both_keys
    assert_raises(ArgumentError) { RubyDM::Questions.noul("x?", criteria: { true: "yes" }) }
  end

  def test_choice_stringifies_keys_and_bounds_size
    q = RubyDM::Questions.choice("team?", criteria: { payments: "money movement" })
    assert_equal({ "payments" => "money movement" }, q["criteria"])

    assert_raises(ArgumentError) { RubyDM::Questions.choice("team?", criteria: {}) }
  end

  def test_score_bounds_size
    assert_raises(ArgumentError) { RubyDM::Questions.score("severity?", criteria: %w[low]) }

    q = RubyDM::Questions.score("severity?", criteria: %w[low high])
    assert_equal(%w[low high], q["criteria"])
  end

  def test_instructions_must_be_non_empty
    assert_raises(ArgumentError) { RubyDM::Questions.noul("") }
    assert_raises(ArgumentError) { RubyDM::Questions.noul(nil) }
    assert RubyDM::Questions.noul({ "a" => 1 })
  end
end
