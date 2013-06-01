require! \./Component.ls

module.exports =
  class ParallaxButton extends Component
    component-name: \ParallaxButton
    template: ({title}) -> "<button>#{title}</button>"
    mutate: !->
    on-attach: !->
      @$.on \click, \button, ->
        alert 'say my name say my name, you acting kinda shady aint callin me baby why the sudden change?'
        return false

      @on-load-resize ||= ~>
        console.log \on-load-resize
        @render-left-half!
        @render-top-half!

      @on-scroll ||= ~>
        console.log \on-scroll
        @render-top-half!

      @@$(window).on 'load resize', @on-load-resize
      @@$(\body).on \scroll, @on-scroll
    on-detach: !->
      @$.off \click, \button
      @@$(window).off 'load resize', @on-load-resize
      @@$(\body).off \scroll, @on-scroll
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
