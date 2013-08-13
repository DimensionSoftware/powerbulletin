require! {
  assert
  Browser: zombie
}

_it = it

describe '/search?q=abra' ->
  @timeout 10000
  # when you need a whole lotta info:
  #b = new Browser {+debug}
  b = new Browser
  browser = b
  describe 'initial load' ->
    _it 'should return a 200 page' (done) ->
      browser.visit 'http://mma.pb.com/search?q=abra' ->
        assert.equal browser.status-code, 200
        done!

    _it 'should have 0 new hits' (done) ->
      assert.equal browser.window.new-hits, 0
      done!

