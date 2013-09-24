require! {
  assert
  \../../component/Paginator
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
    _it "should return ''" !->
      assert.equal c.html(false), ''

describe 'new Paginator {locals: {qty: 16}}' ->
  c = new Paginator {locals: {qty: 16}}

  describe ".html(false)", ->
    expected = '
    <strong class="Paginator-page">1</strong>
    <a href="?page=2" data-page="2" class="mutant Paginator-page">2</a>
    <a href="?page=2" data-page="2" class="mutant Paginator-page">&gt;</a>
    <a href="?page=2" data-page="2" class="mutant Paginator-page">Last</a>
    '

    _it "should return expected html" !->
      assert.equal c.html(false), expected

describe 'new Paginator {locals: {qty: 17}}' ->
  c = new Paginator {locals: {qty: 17}}

  describe ".html(false)", ->
    expected = '
    <strong class="Paginator-page">1</strong>
    <a href="?page=2" data-page="2" class="mutant Paginator-page">2</a>
    <a href="?page=3" data-page="3" class="mutant Paginator-page">3</a>
    <a href="?page=2" data-page="2" class="mutant Paginator-page">&gt;</a>
    <a href="?page=3" data-page="3" class="mutant Paginator-page">Last</a>
    '

    _it "should return expected html" !->
      assert.equal c.html(false), expected

# XXX/TODO would like to create a way to unit test event behaviors without
# having to tie that to a specific application... but for now there is no way
# so this is future work within zombiejs
/*
  describe "subsequently clicking on '2'" ->
    expected = '
    <strong class="Paginator-page">1</strong>
    <a href="?page=2" class="mutant Paginator-page">2</a>
    <a href="?page=3" class="mutant Paginator-page">3</a>
    '

    _it "should invoke the on-page callback" ->
      assert false

    _it "should reload the paginator and return different/new html" ->
      assert false
*/

describe 'new Paginator {locals: {active-page: 2, qty: 16}}' ->
  c = new Paginator {locals: {active-page: 2, qty: 16}}

  describe ".html(false)", ->
    expected = '
    <a href="?page=1" data-page="1" class="mutant Paginator-page">First</a>
    <a href="?page=1" data-page="1" class="mutant Paginator-page">&lt;</a>
    <a href="?page=1" data-page="1" class="mutant Paginator-page">1</a>
    <strong class="Paginator-page">2</strong>
    '

    _it "should return expected html" !->
      assert.equal c.html(false), expected

describe 'new Paginator {locals: {qty: 64}}' ->
  c = new Paginator {locals: {qty: 64}}

  describe ".html(false)", ->
    expected = '
    <strong class="Paginator-page">1</strong>
    <a href="?page=2" data-page="2" class="mutant Paginator-page">2</a>
    <a href="?page=3" data-page="3" class="mutant Paginator-page">3</a>
    <a href="?page=4" data-page="4" class="mutant Paginator-page">4</a>
    <a href="?page=5" data-page="5" class="mutant Paginator-page">5</a>
    <a href="?page=6" data-page="6" class="mutant Paginator-page">6</a>
    <a href="?page=7" data-page="7" class="mutant Paginator-page">7</a>
    <a href="?page=8" data-page="8" class="mutant Paginator-page">8</a>
    <a href="?page=2" data-page="2" class="mutant Paginator-page">&gt;</a>
    <a href="?page=8" data-page="8" class="mutant Paginator-page">Last</a>
    '

    _it "should return expected html" !->
      assert.equal c.html(false), expected

describe 'new Paginator {locals: {qty: 65}}' ->
  c = new Paginator {locals: {qty: 65}}

  describe ".html(false)", ->
    expected = '
    <strong class="Paginator-page">1</strong>
    <a href="?page=2" data-page="2" class="mutant Paginator-page">2</a>
    <a href="?page=3" data-page="3" class="mutant Paginator-page">3</a>
    <a href="?page=4" data-page="4" class="mutant Paginator-page">4</a>
    <a href="?page=5" data-page="5" class="mutant Paginator-page">5</a>
    <a href="?page=6" data-page="6" class="mutant Paginator-page">6</a>
    <a href="?page=7" data-page="7" class="mutant Paginator-page">7</a>
    <a href="?page=8" data-page="8" class="mutant Paginator-page">8</a>
    <a href="?page=9" data-page="9" class="mutant Paginator-page">9</a>
    <a href="?page=2" data-page="2" class="mutant Paginator-page">&gt;</a>
    <a href="?page=9" data-page="9" class="mutant Paginator-page">Last</a>
    '

    _it "should return expected html" !->
      assert.equal c.html(false), expected

describe 'new Paginator {locals: {qty: 129}}' ->
  c = new Paginator {locals: {qty: 129}}

  describe ".html(false)", ->
    expected = '
    <strong class="Paginator-page">1</strong>
    <a href="?page=2" data-page="2" class="mutant Paginator-page">2</a>
    <a href="?page=3" data-page="3" class="mutant Paginator-page">3</a>
    <a href="?page=4" data-page="4" class="mutant Paginator-page">4</a>
    <a href="?page=5" data-page="5" class="mutant Paginator-page">5</a>
    <a href="?page=6" data-page="6" class="mutant Paginator-page">6</a>
    <a href="?page=7" data-page="7" class="mutant Paginator-page">7</a>
    <a href="?page=8" data-page="8" class="mutant Paginator-page">8</a>
    <a href="?page=9" data-page="9" class="mutant Paginator-page">9</a>
    <a href="?page=2" data-page="2" class="mutant Paginator-page">&gt;</a>
    <a href="?page=17" data-page="17" class="mutant Paginator-page">Last</a>
    '

    _it "should return expected html" !->
      assert.equal c.html(false), expected

describe 'new Paginator {locals: {active-page: 10, qty: 129}}' ->
  c = new Paginator {locals: {active-page: 10, qty: 129}}

  describe ".html(false)", ->
    expected = '
    <a href="?page=1" data-page="1" class="mutant Paginator-page">First</a>
    <a href="?page=9" data-page="9" class="mutant Paginator-page">&lt;</a>
    <a href="?page=6" data-page="6" class="mutant Paginator-page">6</a>
    <a href="?page=7" data-page="7" class="mutant Paginator-page">7</a>
    <a href="?page=8" data-page="8" class="mutant Paginator-page">8</a>
    <a href="?page=9" data-page="9" class="mutant Paginator-page">9</a>
    <strong class="Paginator-page">10</strong>
    <a href="?page=11" data-page="11" class="mutant Paginator-page">11</a>
    <a href="?page=12" data-page="12" class="mutant Paginator-page">12</a>
    <a href="?page=13" data-page="13" class="mutant Paginator-page">13</a>
    <a href="?page=14" data-page="14" class="mutant Paginator-page">14</a>
    <a href="?page=11" data-page="11" class="mutant Paginator-page">&gt;</a>
    <a href="?page=17" data-page="17" class="mutant Paginator-page">Last</a>
    '

    _it "should return expected html" !->
      assert.equal c.html(false), expected

