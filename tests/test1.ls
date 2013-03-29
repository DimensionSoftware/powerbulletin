require! {assert, soda}

# workaround for special 'it' in livscript
_it = it

browser = soda.create-client {
  host: \localhost
  port: 4444
  url: 'http://mma.pb.com'
  browser: \firefox
}

browser.session ->
  browser.open '/' ->
    browser.get-title (err, title) ->
      if err then throw err
      console.log title
      browser.test-complete (->)

describe "when going to the homepage" ->
  _it 'should be 1' ->
    assert 1 is 1
  _it 'should not go b00m' ->
    throw new Error \b00m
  #TODO: i want to propagate client errors in the browser which selenium runs so we see it in the console

