require! {
  assert
  PhotoCropper: \../../component/PhotoCropper
}

_it = it

describe 'new PhotoCropper' ->
  _it 'should throw an exception since it requires locals' ->
    assert.throws -> new PhotoCropper

describe 'new PhotoCropper {locals}' ->
  locals =
    title: 'foo'
    endpoint-url: '/foo'
    cache-url: 'http://foo.com'
    photo: '/foo.png'

  expected = '
  <div class="PhotoCropper"><div class="upload"><form method="POST" action="/foo" enctype="multipart/form-data"><h1>foo</h1><div><img src="http://foo.com/foo.png"></div><div><div class="button"> <span>Change Profile Photo</span><input type="file" name="avatar"></div></div></form></div><div style="display:none;" class="crop"><h1>Crop Mode</h1><p>This is where</p></div></div>
  '

  pc = new PhotoCropper {locals}

  #_it "should be in upload mode" ->
  #  assert(pc.html!.index-of('<div style="display:none;" class="crop">') isnt -1)
  #  assert(pc.html!.index-of('<div class="upload">') isnt -1)

  _it ".html! should return some html ... (pretty fuzzy)" ->
    assert pc.html!match(/^<div class="PhotoCropper">/)

  # XXX
  # DOH! this test won't work because hide! doesn't exists in cheerio
  #_it 'should be in crop mode after calling crop-mode!' ->
  #  pc.crop-mode!
  #  assert(pc.html!.index-of('<div class="crop">') isnt -1)
  #  assert(pc.html!.index-of('<div style="display:none;" class="upload">') isnt -1)
    
