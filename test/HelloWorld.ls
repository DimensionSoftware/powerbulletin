require! {
  assert
  \../component/HelloWorld
}

_it = it

describe 'new HelloWorld' ->
  h = new HelloWorld

  describe ".render!" ->
    markup = '<div class="HelloWorld"><p>Hello, World</p></div>'

    _it "should return '#{markup}'" ->
      assert.equal h.render!, markup

describe "new HelloWorld {name:'Matt'}" ->
  h = new HelloWorld {name: 'Matt'}

  describe ".render!" ->
    markup = '<p>Hello, World</p> <strong>Matt!</strong>'
    markup = '<div class="HelloWorld"><p>Hello, World</p> <strong>Matt!</strong></div>'

    _it "should return '#{markup}'" ->
      assert.equal h.render!, markup
