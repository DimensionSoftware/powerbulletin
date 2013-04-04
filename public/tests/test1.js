describe('test data', function(){
  var expect = chai.expect
  it('should be loaded', function(){
    window.$('#query').focus().val('foo')
    // XXX: replace with bacon streams to ease testing?
    window.$(document).trigger('search')

    expect(window.location.pathname).to.equal('/search')
  })
})
