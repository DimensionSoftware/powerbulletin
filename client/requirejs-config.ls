define = window?define or require(\amdefine) module
require, exports, module <- define

cache-url =
  if window?
    window.cache-url
  else
    require \../app/load-cvars
    cvars.cache-url

base-url: "#{cache-url}/client" # override for optimized builds
paths:
  fse                   : "../local/fse"
  #jquery                : \//cdnjs.cloudflare.com/ajax/libs/jquery/2.0.3/jquery.min
  jquery                : "../local/jquery-1.9.1.min"
  jquery-cookie         : "../local/jquery.cookie-1.3.1.min"
  jquery-history        : "../local/history.min"
  jquery-html5-uploader : "../local/jquery.html5uploader"
  jquery-masonry        : "../local/jquery.masonry.min"
  jquery-nicescroll     : "../local/jquery.nicescroll.min"
  jquery-transit        : "../local/jquery.transit-0.9.9.min"
  jquery-ui             : "../local/jquery-ui.min"
  jquery-waypoints      : "../local/waypoints.min"
  lodash                : \//cdnjs.cloudflare.com/ajax/libs/lodash.js/1.3.1/lodash.min
  raf                   : "../local/raf"
  powerbulletin         : "../powerbulletin"
  powerbulletin-sales   : "../powerbulletin-sales"
shim:
  lodash:
    exports: \_
    init: -> window._
  jquery:
    exports: \jQuery
  jquery-cookie:
    exports: \jQuery.cookie
    deps: [\jquery]
  jquery-history:
    exports: \History.adapter
    deps: [\jquery]
  jquery-masonry:
    # no exports property needed since masonry is native AMD
    deps: [\jquery]
  jquery-nicescroll:
    exports: \jQuery.nicescroll
    deps: [\jquery]
  jquery-transit:
    exports: \jQuery.transit
    deps: [\jquery]
  jquery-ui:
    exports: \jQuery.ui
    deps: [\jquery]
  jquery-waypoints:
    exports: \jQuery.waypoints
    deps: [\jquery]
  raf:
    exports: \raf
map:
  '*':
    cheerio: \jquery
packages:
  * name: \mutant
    location: \../packages/mutant
    main: \index.js
  * name: \prelude-ls
    location: \../packages/prelude-ls/lib
    main: \index.js
  * name: \reactivejs
    location: \../packages/reactivejs
    main: \src/reactive.js
  * name: \yacomponent
    location: \../packages/yacomponent

out: \../public/pb-optimized.js
name: \pb-entry
optimize: \none # can be 'none', 'uglify', 'uglify2', or 'closure'
