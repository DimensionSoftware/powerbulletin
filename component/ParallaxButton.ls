define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  \./PBComponent
  $R:reactivejs
}

module.exports =
  class ParallaxButton extends PBComponent
    template: ({title}) -> "<button>#{title}</button>"
    ({@on-click = (->)}) ->
      super ...

    on-attach: !->
      @$.on \click, \button, ~>
        @on-click!
        return false

      @on-load-resize ||= ~>
        @render-left-half!
        @render-top-half!

      @on-scroll ||= ~>
        @render-top-half!

      #XXX: disable this until we can troubleshoot it
      #FIXME: can't i have a parallax button? :(
      #@@$(window).on 'load resize', @on-load-resize
      #@@$(window).on \scroll, @on-scroll
    on-detach: !->
      @$.off \click, \button
      @@$(window).off 'load resize', @on-load-resize
      @@$(window).off \scroll, @on-scroll
    render-top-half: !->
      $button = @$.find \button
      off-top = $button.offset!top
      scr-top = @@$(window).scroll-top!
      half-window-height = @@$(window).height! / 2
      $button.toggle-class \top-half, off-top - scr-top < half-window-height
    render-left-half: !->
      $button = @$.find \button
      off-left = $button.offset!left
      half-window-width = @@$(window).width! / 2
      $button.toggle-class \left-half, off-left < half-window-width
    enable: !->
      @$.find('button').attr \disabled, null
      @attach!
    disable: !->
      @$.find('button').attr \disabled, true
      @detach!
