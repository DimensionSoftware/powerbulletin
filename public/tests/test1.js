describe('homepage', function(){
  this.timeout(15000)
  var expect = chai.expect

  it('typing keywords should take you to /search', function(done){
    window.$('#query').focus().val('foo')
    // XXX: replace with bacon streams to ease testing?
    window.$(document).trigger('search')

    function work() {
      //expect(window.location.pathname).to.equal('/search')
      // XXX: create helper for this to make error reporting better
      // and test writing with callbacks less verbose
      // big thanks to this thread:
      // http://stackoverflow.com/questions/11235815/is-there-a-way-to-get-chai-working-with-asynchronous-mocha-tests
      try {
        expect(window.location.pathname).to.equal('/search')
        done()
      } catch(e) {
        done(e)
      }
    }
    // allow 5000ms for the app to complete its search routine
    setTimeout(work, 5000)
  })

  it('should be able to mutate to the training forum', function(done){
    window.$("a.mutant[href='/training-forum']:first").trigger('click')

    function work() {
      try {
        expect($('html.forum-3').length).to.equal(1)
        done()
      } catch(e) {
        done(e)
      }
    }
    // allow 10000ms for the app to complete its mutation 
    setTimeout(work, 10000)
  })
})
