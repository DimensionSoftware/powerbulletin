require! {
  assert
  sh: \../../shared/shared-helpers
}

_it = it

e2hr-should-equal = (text, ...durations) ->
  for dur in durations
      _it "elapsed-to-human-readable(#{dur}s) => #{JSON.stringify text}" ->
        assert.equal sh.elapsed-to-human-readable(dur), text

describe 'function elapsed-to-human-readable' ->
  e2hr-should-equal 'Just now!' -34 -1 0 1 13 28 29
  e2hr-should-equal 'A moment ago' 31 45 52 59
  e2hr-should-equal 'A minute ago' 60 77 99 119
  e2hr-should-equal '<b>3</b> minutes ago' 120 121 131 180 181 239
  e2hr-should-equal '<b>4</b> minutes ago' 240
