require! {
  assert
  \../component/Component
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
    _it "should throw Error" ->
      assert.throws c.attach

  describe ".locals!", ->
    _it "should be {}" ->
      assert.deep-equal {}, c.locals!

  describe ".local \\reactiveFun, 1" ->
   
    _it "should throw an Error since only reactive state can be set" ->
      c.state.reactive-fun = $R(->)
      assert.throws (-> c.local(\reactiveFun, 1))

  describe ".detach!", ->
    _it "should throw Error" ->
      assert.throws c.detach

  describe ".html!", ->
    markup = '<div class="Component"></div>'
    _it "should return '#{markup}'" !->
      assert.equal c.html!, markup

  describe ".html(false)", ->
    _it "should return ''" !->
      assert.equal c.html(false), ''

describe "new Component {} $dom" !->
  $dom = $ '<div><div/></div>'
  $container = $dom.find \div
  c = new Component {render: true} $container

  describe '$dom' !->
    _it "should be rendered to" !->
      markup = '<div class="Component"></div>'
      assert.equal markup, $dom.html!
