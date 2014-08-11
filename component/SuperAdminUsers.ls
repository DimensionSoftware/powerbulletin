define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  \./PBComponent
  \./Table
}

{lazy-load-fancybox} = require \../client/client-helpers

# responsible for url token superUsers
module.exports =
  class SuperAdminUsers extends PBComponent
    title: 'Edit Users'
    init: ->
      pnum-to-href = (pg) ~>
        base = @local(\gen) \superUsers
        if parse-int(pg) > 1
          base + "?page=#pg"
        else
          base

      # table locals
      s = @state
      locals = {
        s.cols
        s.rows
        s.qty
        s.active-page
        s.step
      }
      @children = {table: new Table {locals, pnum-to-href} \.SuperAdminUsers-table @}
    on-attach: ->
      dollarish = @@$
      @$.on \click \.onclick-export-email ->
        console.log \here

#      @$.on \click 'a[data-edit-user]' ->
#        user = dollarish @ .data \edit-user
#
#        finish = (UserEditor) ->
#          window.$.fancybox (new UserEditor {locals: {user}}).$
#          false
#
#        <- lazy-load-fancybox
#
#        # lazy load at moment that user clicks on item
#        #XXX:  WHYYYYYY?!?!?
#        # workaround for weird requirejs issue with async api
#        try
#          require [\./UserEditor], finish
#        catch
#          require [\./UserEditor], finish
