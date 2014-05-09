require! {
  \./fsm
}

/*

NOTES ON BBCODE

  Tag Types

    Simple              = [b]bold[/b]
    One Paramter        = [url=http://foobar]foobar[/url]
    Multiple Parameter  = [img width=32 height=32]http://foobar/img.png[/img]
    Xist Item Shortcut  = [*] Xist item\n

  Can I write functions that generate a state machine for each of these types?

inputs:
  [
  ]
  /
  *
  =
  letters -- I'm at a place where I need to figure out hierarchical fsm's or suffer.
    If I don't modularize this, the number of inputs in the main machine would be huge.
      I should be allowed to jump to a completely different state machine that takes completely different inputs.
        I need do the input type checking later in the process sometimes.
        I need to consume raw data and let each state machine categorize the inputs it consumes.
          One size DOES NOT fit all state machines.
          What's irrelevant to one state machine may be very relevant to another.

inputs i forgot:
  LF   -- linefeed is part of bbcode syntax because of [*] list item Shortcut
  ' '  -- white space has meaning

states:
  text
  [
  $tag
  $tag=
  ]
  end

*/

export tag =
  simple: (name) ->
    {}
  one-parameter: (name) ->
    {}
  multiple-parameter: (name, params=[]) ->
    {}
  list-item-shortcut: ->
    {}

export machine =
  start:
    '[': '-maybe-tag-start'
    ']': \text1
    '/': \text1
    '*': \text1
    '=': \text1
    'X': \text1
  text1: # text outside of a tag
    '[': '-maybe-tag-start'
    ']': \text1
    '/': \text1
    '*': \text1
    '=': \text1
    'X': \text1
  '-maybe-tag-start': # This needs to be a function that has a bigger understanding of the X input so it can identify different tags.
    '[': \text1
    ']': \text1
    '/': \-maybe-close-x-tag
    '*': \-maybe-list-item-shortcut
    '=': \text1
    'X': \-maybe-open-x-tag
  '-maybe-open-x-tag':
    '[': \text1
    ']': \open-x-tag
    '/': \text1
    '*': \text1
    '=': \text1
    'X': \-maybe-open-x-tag
  'open-x-tag':
    '[': '-maybe-tag-start-or-stop'
    ']': \text2
    '/': \text2
    '*': \text2
    '=': \text2
    'X': \text2
  '-maybe-tag-start-or-stop':
    '[': \text2
    ']': \text2
    '/': '-maybe-tag-stop'
    '*': \text2
    '-': \text2
    'X': \-maybe-open-x-tag
  '-maybe-tag-stop':
    '[': \text2
    ']': \text2
    '/': \text2
    '*': \text2
    '=': \text2
    'X': \-maybe-close-x-tag
  '-maybe-close-x-tag':
    '[': \text2
    ']': \close-x-tag
    '/': \text2
    '*': \text2
    '=': \text2
    'X': \-maybe-close-x-tag
  text2: # text inside of a tag
    '[': '-maybe-tag-start-or-stop'
    ']': \text2
    '/': \text2
    '*': \text2
    '=': \text2
    'X': \text2
  'close-x-tag':
    '[': '-maybe-tag-start-or-stop'
    ']': \text2
    '/': \text2
    '*': \text2
    '=': \text2
    'X': \text2

export type-of = (char) ->
  switch char 
  | '[' => '['
  | ']' => ']'
  | '/' => '/'
  | '*' => '*'
  | '=' => '='
  | otherwise => 'X'

# TODO - scan bbcode string into lexical types
export scan = (string) ->
  chars = string.split ''
  inputs = map type-of, chars
  zip (fsm.all-states machine, \start, inputs), [...chars, \EOF ]

# TODO - json-ml from bbcode string
export json-ml = (string) ->
  s = scan string
  # interpret s further; build a tree out of this stream; handle incomplete markup gracefully

# TODO - html from bbcode string
export html = (string) ->
  j = json-ml string
