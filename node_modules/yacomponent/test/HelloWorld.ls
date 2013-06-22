require! {
  assert
  \../HelloWorld
}

_it = it

describe 'new HelloWorld' ->
  h = new HelloWorld

  describe ".html!" ->
    markup = '<div class="HelloWorld"><p>Hello, World</p></div>'

    _it "should return '#{markup}'" ->
      assert.equal h.html!, markup

describe "new HelloWorld {locals: {name:'Matt'}}" ->
  h = new HelloWorld {locals: {name: 'Matt'}}

  describe ".html!" ->
    markup = '<div class="HelloWorld"><p>Hello, World</p> <strong>Matt!</strong></div>'

    _it "should return '#{markup}'" ->
      assert.equal h.html!, markup
