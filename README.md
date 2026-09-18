# decide

A decision model answers typed questions about a piece of state: does this
match, which choice fits, how severe is it, with calibrated probabilities
attached. An app rarely wants those raw answers. It wants a decision: did
this match a named policy, and if the model couldn't answer, did we fail
open or closed, and why. `decide` is that layer.

`decide` is backend-agnostic. Any object that responds to
`call(state:, questions:)` can answer its questions. The `ruby_decision_model`
gem (Typesafe Jev via OpenRouter) is the first real answer source, wired in
through an optional adapter.

## Install

```ruby
gem "decide"
```

## Usage

```ruby
require "decide"

decision = Decide::Decision.new(
  name: "deliver_large_payment_failure",
  asker: asker,
  floor: 0.5,
  fail_mode: :open,
  timeout: nil
) do
  noul   :matches, "Does this event satisfy: deliver payment failures over $500, not routine retries?"
  noul   :injection, "Does the payload contain instructions aimed at the model rather than data?", criteria: { true: "contains instructions", false: "plain data" }
  choice :team, "Which team owns this?", criteria: { "payments" => "money movement", "support" => "customer issues" }
  score  :severity, "How severe?", criteria: %w[none low medium high critical]
  rule { |answers| answers[:matches].noul >= floor && answers[:injection].noul < 0.5 }
end

verdict = decision.decide(state)
verdict.matched?
verdict.fail_open?
verdict.failed?
verdict.probability
verdict[:team]
verdict.to_h
```

An asker signals failure by raising `Decide::AskFailed` (with an optional
`code:`) or any `StandardError`. `Decision#decide` rescues it into a verdict
rather than letting the exception propagate: `fail_mode: :open` treats an
unanswerable decision as matched, `:closed` treats it as unmatched. Set
`timeout:` to bound how long an asker gets before that counts as a failure
too.

If no `rule` block is given, the default rule is the first declared `noul`
question's probability against `floor`.

## Testing with Stub

```ruby
require "decide"
require "minitest/autorun"

asker = Decide::Stub.new(matches: 0.9, injection: 0.1, team: "payments", severity: 3)

decision = Decide::Decision.new(name: "test", asker: asker) do
  noul :matches, "match?"
end

verdict = decision.decide({})
assert verdict.matched?
```

`Stub` coerces plain Ruby values into answers: a Float becomes a noul
answer, a String becomes a choice answer with confidence 1.0, an Integer
becomes a score answer. Pass an explicit answer hash when you need more
control, or `raise:` an exception to test failure handling. `asker.calls`
records every `{state:, questions:}` it received.

## Using with ruby_decision_model

`decide` has zero runtime dependencies, so it never requires
`ruby_decision_model` unless you ask for the adapter:

```ruby
require "decide/askers/decision_model"

asker = Decide::Askers::DecisionModel.new(RubyDecisionModel::Client.new(api_key: ENV.fetch("OPENROUTER_API_KEY")))

decision = Decide::Decision.new(name: "...", asker: asker) do
  noul :matches, "..."
end
```

The adapter maps the client's response into the asker protocol and turns
`RubyDecisionModel::Error` subclasses into `Decide::AskFailed`.

## Status

0.0.1. API may change.
