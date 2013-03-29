require! {soda}

browser = soda.create-client {
  host: \localhost
  port: 4444
  url: 'http://www.google.com'
  browser: \firefox
}

browser.session ->
  browser.open '/' ->
    browser.get-title (err, title) ->
      if err then throw err
      console.log title
      browser.test-complete (->)
