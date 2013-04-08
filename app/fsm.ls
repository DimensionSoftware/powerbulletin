# Examples:
#   fsm.new-state fsm.example, \A, [\a \a \a]
#   fsm.new-state fsm.example, \B, [\a]
#   fsm.new-state fsm.example, \C, [\a]
#   fsm.new-state fsm.example, \C, [\b]
/*
export example =
  A:
    a: "B"
    b: "C"
  B:
    a: "A"
    b: "C"
  C:
    a: "C"
    b: "C"
*/

# new state of a state machine given an initial state and a list of inputs
export new-state = (machine, state, inputs) ->
  transition = (s, i) -> machine[s][i]
  fold transition, state, inputs
