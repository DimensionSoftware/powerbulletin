export foo = ->
  mylst =
    * 33
    * 34
    * 77
    * 88
    * 11
  plv8.execute 'select * from users', []
