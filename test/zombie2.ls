require! {
  assert
  Browser: zombie
  \../component/Paginator
}

_it = it

describe 'homepage' ->
  @timeout 15000
  b = new Browser
  browser = b
  describe 'initial load' ->
    _it 'should return a 200 page' (done) ->
      browser.visit 'http://pb.com' {wait-for: 10000} ->
        assert.equal browser.status-code, 200
        done!
  # XXX/FIXME: this test is broken`
  #describe 'when creating new site "sillygoose.pb.com"' ->
  #  expected-location = "http://sillygoose.pb.com/"
  #  _it "should redirect to '#{expected-location}'" (done) ->
  #    browser.fill \.Sales-subdomain \sillygoose
  #    <- browser.wait
  #    browser.press-button '.Sales-create button'
  #    <- browser.wait
  #    assert.equal browser.window.location.to-string!, expected-location
  #    done!
