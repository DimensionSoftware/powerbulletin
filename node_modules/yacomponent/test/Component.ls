require! {
  assert
  \../src/Component
  $: cheerio
  $R: reactivejs
}

_it = it

describe 'new Component' ->
  c = new Component

  describe ".template!" ->
    _it "should return ''" ->
      assert.equal '', c.template!

  describe ".attach!" ->
    _it "should return @" ->
      assert.equal c.attach!, c

  describe ".detach!", ->
    _it "should return @" ->
      assert.equal c.detach!, c

  describe ".locals!", ->
    _it "should be {}" ->
      assert.deep-equal {}, c.locals!

  describe ".html!", ->
    markup = '<div class="Component"></div>'
    _it "should return expected markup" !->
      assert.equal c.html!, markup

  describe ".html(false)", ->
    _it "should return ''" !->
      assert.equal c.html(false), ''

  expected = {a:1,b:2}
  describe ".locals(#{JSON.stringify expected})", ->
    _it "should return #{JSON.stringify expected}" !->
      assert.deep-equal c.locals(expected), expected

    _it "should setup two locals: a and b" !->
      assert.deep-equal c.locals!, expected

  describe ".locall(\\b)", ->
    _it "should return 2" !->
      assert.equal c.local(\b), 2

  describe ".locall(\\foo)", ->
    _it "should return void" !->
      assert.equal c.local(\foo), void

  describe ".locall(\\foo, 1)", ->
    _it "should return 1" !->
      assert.equal c.local(\foo, 1), 1

    _it "should create a reactive state named \\foo" !->
      assert c.state.foo._is-reactive
      old-foo = c.state.foo

    _it "should create a reactive state named \\foo which resolves to 1" !->
      assert.equal c.state.foo!, 1

    var old-foo

    _it "should return 2 when called again with (\\foo, 2)" !->
      old-foo := c.state.foo
      assert.equal c.local(\foo, 2), 2

    _it "should reuse the reactive state named \\foo when called again with (\\foo, 2)" !->
      assert.equal c.state.foo, old-foo

  describe ".local \\reactiveFun, 1" ->
    _it "should throw an Error since only reactive state can be set" ->
      c.state.reactive-fun = $R(->)
      assert.throws (-> c.local(\reactiveFun, 1))

describe "new Component {} $dom" !->
  $dom = $ '<div><div/></div>'
  $container = $dom.find \div
  c = new Component {render: true} $container

  describe '$dom' !->
    _it "should be rendered to" !->
      markup = '<div class="Component"></div>'
      assert.equal markup, $dom.html!
