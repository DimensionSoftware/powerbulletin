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
  e2hr-should-equal '<b>Just now!</b>' -34 -1 0 1 13 28 29
  e2hr-should-equal '<b>a moment ago</b>' 31 45 52 59
  e2hr-should-equal '<b>a minute ago</b>' 60 77 99 119
  e2hr-should-equal '<b>3 minutes</b> ago' 120 121 131 180 181 239
  e2hr-should-equal '<b>4 minutes</b> ago' 240
