require! {
  assert
  \../component/Parent
}

_it = it

describe 'new Parent' ->
  p = new Parent

  describe ".html!" ->
    markup = '<div class="Parent"><div class="Parent-hw HelloWorld"><p>Hello, World</p></div></div>'

    _it "should return '#{markup}'" ->
      assert.equal p.html!, markup
