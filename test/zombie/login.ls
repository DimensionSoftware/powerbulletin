require! {
  assert
  Browser: zombie
}

_it = it

describe 'homepage' ->
  @timeout 15000
  b = new Browser
  browser = b
  describe 'initial load' ->
    _it 'should return a 200 page' (done) ->
      browser.visit 'http://mma.pb.com' {wait-for: 10000} ->
        assert.equal browser.status-code, 200
        done!

  #XXX/FIXME: test broken
  #describe 'login' ->
  #  _it "should display the login dialog" (done) ->
  #    <- browser.fire 'menu.tools .onclick-login', 'click'
  #    <- browser.wait
  #    assert browser.window.$('.fancybox-wrap:visible').length
  #    done!

