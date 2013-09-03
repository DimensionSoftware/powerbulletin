define = window?define or require(\amdefine) module
require, exports, module <- define

cache-url =
  if window?
    window.cache-url
  else
    require \../app/load-cvars
    require! fs
    cvars.cache-url

base-url: "#{cache-url}/client" # override for optimized builds
wait-seconds: 14 # give a single module this long to load til timeout
paths:
  fse                   : "../local/fse"
  #jquery                : "../local/jquery-1.9.1.min"
  #jquery                : \//cdnjs.cloudflare.com/ajax/libs/jquery/1.9.1/jquery.min
  jquery                : \//cdnjs.cloudflare.com/ajax/libs/jquery/1.10.2/jquery.min
  #jquery-cookie         : "../local/jquery.cookie-1.3.1.min"
  jquery-cookie         : \//cdnjs.cloudflare.com/ajax/libs/jquery-cookie/1.3.1/jquery.cookie.min
  jquery-history        : "../local/history.min"
  jquery-html5-uploader : "../local/jquery.html5uploader"
  #jquery-masonry        : \//cdnjs.cloudflare.com/ajax/libs/masonry/3.1.1/masonry.pkgd.min
  # above didn't work because amd tried to resolve sub-modules ^^
  jquery-masonry        : "../local/jquery.masonry.min"
  jquery-nicescroll     : "../local/jquery.nicescroll.min"
  #jquery-transit        : "../local/jquery.transit-0.9.9.min"
  jquery-transit        : \//cdnjs.cloudflare.com/ajax/libs/jquery.transit/0.9.9/jquery.transit.min
  #jquery-ui             : "../local/jquery-ui.min"
  jquery-ui             : \//cdnjs.cloudflare.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min
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
# excludeShallow items which we do not want uglified...
# right now I am doing it to all components, since we don't want class name mangled
# this is undefined on client-side, this option is only needed when creating an optimized build
exclude-shallow: ["../component/#{f.slice(0, -3)}" for f in fs.readdir-sync('component') when f.match /.ls$/i] unless window?
optimize: \uglify # can be 'none', 'uglify', 'uglify2', or 'closure'
