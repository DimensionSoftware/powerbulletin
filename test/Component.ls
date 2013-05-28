require! {
  assert
  \../component/Component
  $: cheerio
}

_it = it

describe 'new Component' !->
  c = new Component

  describe ".template!" !->
    _it "should return ''" !->
      assert.equal '', c.template!

  describe ".attach!" !->
    _it "should return void" !->
      assert.equal void, c.attach!

  describe ".detach!", !->
    _it "should return void" !->
      assert.equal void, c.detach!

  describe ".state!", !->
    _it "should return {}" !->
      assert.deep-equal {}, c.state!

  describe ".html", !->
    _it "should be void" !->
      assert.equal void, c.html

  describe ".render!", !->
    _it "should return ''" !->
      assert.equal '', c.render!

  describe ".html should now be '' after rendering", !->
    _it "should be ''" !->
      assert.equal '', c.html

  describe ".put", !->
    _it "should throw Error" !->
      assert.throws c.put

describe "new Component {} $content" !->
  describe '.put' !->
    $content = $ '<p>content which should be replaced</p>'
    c = new Component {} $content
    c.put!

    _it "should populate $content.html! with ''" !->
      assert.equal '', $content.html!

