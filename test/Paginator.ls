require! {
  assert
  \../component/Paginator
}

_it = it

describe 'new Paginator' ->
  c = new Paginator

  describe ".locals!", ->
    default-locals =
      active-page: 1
      step: 8
      qty: 0
      page-distance: 4
      page-qty: 0
      pages: []

    _it "should return default values" ->
      assert.deep-equal default-locals, c.locals!

  describe ".html(false)", ->
    _it "should return ''" !->
      assert.equal c.html(false), ''

describe 'new Paginator {locals: {qty: 8}}' ->
  c = new Paginator {locals: {qty: 8}}

  describe ".html(false)", ->
    expected = '<strong class="Paginator-page">1</strong>'
    _it "should return #expected" !->
      assert.equal c.html(false), expected

describe 'new Paginator {locals: {qty: 16}}' ->
  c = new Paginator {locals: {qty: 16}}

  describe ".html(false)", ->
    expected = '
    <strong class="Paginator-page">1</strong>
    <a href="?page=2" class="Paginator-page">2</a>
    '

    _it "should return #expected" !->
      assert.equal c.html(false), expected

describe 'new Paginator {locals: {qty: 17}}' ->
  c = new Paginator {locals: {qty: 17}}

  describe ".html(false)", ->
    expected = '
    <strong class="Paginator-page">1</strong>
    <a href="?page=2" class="Paginator-page">2</a>
    <a href="?page=3" class="Paginator-page">3</a>
    '

    _it "should return #expected" !->
      assert.equal c.html(false), expected

describe 'new Paginator {locals: {active-page: 2, qty: 16}}' ->
  c = new Paginator {locals: {active-page: 2, qty: 16}}

  describe ".html(false)", ->
    expected = '
    <a href="?page=1" class="Paginator-page">1</a>
    <strong class="Paginator-page">2</strong>
    '

    _it "should return #expected" !->
      assert.equal c.html(false), expected
