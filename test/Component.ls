require! {
  assert
  \../component/Component
  $: cheerio
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

  describe ".detach!", ->
    _it "should throw Error" ->
      assert.throws c.detach

  describe ".locals", ->
    _it "should be {}" ->
      assert.deep-equal {}, c.locals

  describe ".html!", ->
    markup = '<div class="Component"></div>'
    _it "should return '#{markup}'" !->
      assert.equal markup, c.html!

describe "new Component {} $dom" !->
  $dom = $ '<div><div/></div>'
  $container = $dom.find \div
  c = new Component {render: true} $container

  describe '$dom' !->
    _it "should be rendered to" !->
      markup = '<div class="Component"></div>'
      assert.equal markup, $dom.html!
