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
wait-seconds: 60s # give a single module this long to load till timeout
paths:
  fse                   : "../local/fse"
  jquery                : \../local/jquery-1.10.2.min
  jquery-history        : "../local/history.min"
  jquery-html5-uploader : "../local/jquery.html5uploader"
  #jquery-masonry        : \//cdnjs.cloudflare.com/ajax/libs/masonry/3.1.1/masonry.pkgd.min
  # above didn't work because amd tried to resolve sub-modules ^^
  jquery-masonry        : "../local/jquery.masonry.min"
  jquery-transit        : if env is \production then \//cdnjs.cloudflare.com/ajax/libs/jquery.transit/0.9.9/jquery.transit.min else \../local/jquery.transit-0.9.9.min
  jquery-ui             : if env is \production then \//cdnjs.cloudflare.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min else \../local/jquery-ui.min
  #jquery-waypoints      : if env is \production then \//cdnjs.cloudflare.com/ajax/libs/waypoints/2.0.3/waypoints.min else \../local/waypoints.min
  # above didn't work because of loading order?
  jquery-waypoints      : \../local/waypoints.min
  jquery-iris           : \../local/iris.min
  lodash                : if env is \production then \//cdnjs.cloudflare.com/ajax/libs/lodash.js/1.3.1/lodash.min else \../local/lodash.min
  pd-editor             : if env is \production then \//cdnjs.cloudflare.com/ajax/libs/pagedown/1.0/Markdown.Editor.min else \../local/pagedown/Markdown.Editor
  #pagedown              : if env is \production then \//cdnjs.cloudflare.com/ajax/libs/pagedown/1.0/Markdown.Sanitizer.min else \../local/pagedown/Markdown.Sanitizer
  #jquery-fancybox       : if env is \production then \//cdnjs.cloudflare.com/ajax/libs/fancybox/2.1.5/jquery.fancybox.pack else \../local/jquery.fancybox.pack
  #socketio              : if env is \production then \//cdnjs.cloudflare.com/ajax/libs/socket.io/0.9.16/socket.io.min else \../local/socket.io.min
  pd-converter          : if env is \production then \//cdnjs.cloudflare.com/ajax/libs/pagedown/1.0/Markdown.Converter.min else \../local/pagedown/Markdown.Converter
  pd-sanitizer          : if env is \production then \//cdnjs.cloudflare.com/ajax/libs/pagedown/1.0/Markdown.Sanitizer.min else \../local/pagedown/Markdown.Sanitizer
  raf                   : \../local/raf
  strftime              : \../local/strftime
  powerbulletin         : \../powerbulletin
  powerbulletin-sales   : \../powerbulletin-sales
  #pagedown              : ["../local/Markdown.Converter", "../local/Markdown.Sanitizer"]
shim:
  lodash:
    exports: \_
    init: -> window._
  jquery-history:
    exports: \History.Adapter
    deps: [\jquery]
  jquery-masonry:
    deps: [\jquery]
    exports: \jQuery.Mason
  jquery-transit:
    exports: \jQuery.transit
    deps: [\jquery]
  jquery-ui:
    exports: \jQuery.ui
    deps: [\jquery]
  jquery-waypoints:
    exports: \jQuery.waypoints
    deps: [\jquery]
  pd-converter:
    exports: \Markdown.Converter
    deps: [\pdSanitizer]
  pd-sanitizer:
    exports: \Markdown.Sanitizer
  pd-editor:
    exports: \Markdown.Editor
    deps: [\pdConverter]
    init: -> window.Markdown.Editor
  raf:
    exports: \raf
  strftime:
    exports: \strftime
    init: -> window.strftime
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
#exclude-shallow: ["../component/#{f.slice(0, -3)}" for f in fs.readdir-sync('component') when f.match /.ls$/i] unless window?
optimize: \uglify # can be 'none', 'uglify', 'uglify2', or 'closure'
