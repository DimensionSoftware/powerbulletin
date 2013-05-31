require! {
  assert
  \../component/Parent
}

_it = it

describe 'new Parent' ->
  p = new Parent

  describe ".render!" ->
    markup = '<div class="Parent"><div class="HelloWorld"><p>Hello, World</p></div></div>'

    _it "should return '#{markup}'" ->
      assert.equal p.render!, markup
