require! {
  assert
  Browser: zombie
  \../component/Paginator
}

_it = it

describe 'homepage' ->
  b = new Browser
  browser = b
  describe 'initial load' ->
    _it 'should return a 200 page' (done) ->
      @timeout 15000
      browser.visit 'http://pb.com' {timeout: 10000} ->
        assert.equal browser.status-code, 200
        done!
        #assert.ok browser.success
  #  ((browser.fill 'email', 'zombie@underworld.dead').fill 'password', 'eat-the-living').pressButton 'Sign Me Up!', ->
  #    assert.ok browser.success
  #    assert.equal (browser.text 'title'), 'Welcome To Brains Depot'
