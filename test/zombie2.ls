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
        #assert.ok browser.success
  describe 'when creating new site "sillygoose.pb.com"' ->
    expected-location = "http://sillygoose.pb.com/"
    _it "should redirect to '#{expected-location}'" (done) ->
      browser.fill \.Sales-subdomain \sillygoose
      <- browser.wait
      browser.press-button '.Sales-create button'
      <- browser.wait
      #console.log browser.html!
      #console.log browser.window.location.to-string!
      assert.equal browser.window.location.to-string!, expected-location
      done!
  #  ((browser.fill 'email', 'zombie@underworld.dead').fill 'password', 'eat-the-living').pressButton 'Sign Me Up!', ->
  #    assert.ok browser.success
  #    assert.equal (browser.text 'title'), 'Welcome To Brains Depot'
