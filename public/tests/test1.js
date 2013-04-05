describe('test data', function(){
  var expect = chai.expect
  it('should be loaded', function(done){
    window.$('#query').focus().val('foo')
    // XXX: replace with bacon streams to ease testing?
    window.$(document).trigger('search')

    function w() {
      expect(window.location.pathname).to.equal('/search')
      done()
    }
    // allow 1000 ms for the app to complete its search routine
    setTimeout(w, 1000)
  })
})
