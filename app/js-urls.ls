# this module is to coordnate all client-side dependencies
# so if we update it in one spot it updates in all spots...
#
# assumes cvars is present
module.exports =
  jquery                : "#{cvars.cache5-url}/local/jquery-1.9.1.min.js"
  jquery-ui             : "#{cvars.cache5-url}/local/jquery-ui.min.js"
  jquery-masonry        : "#{cvars.cache3-url}/local/jquery.masonry.min.js"
  jquery-cookie         : "#{cvars.cache2-url}/local/jquery.cookie-1.3.1.min.js"
  jquery-sceditor       : "#{cvars.cache4-url}/local/jquery.sceditor.bbcode.min.js"
  jquery-waypoints      : "#{cvars.cache-url}/local/waypoints.min.js"
  jquery-history        : "#{cvars.cache5-url}/local/history.min.js"
  jquery-fancybox       : "#{cvars.cache4-url}/fancybox/jquery.fancybox.pack.js"
  jquery-transit        : "#{cvars.cache3-url}/local/jquery.transit-0.9.9.min.js"
  jquery-html5-uploader : "#{cvars.cache2-url}/local/jquery.html5uploader.js"
  jquery-jcrop          : "#{cvars.cache2-url}/jcrop/js/jquery.Jcrop.min.js"
  jquery-nicescroll     : "#{cvars.cache3-url}/local/jquery.nicescroll.min.js"
  raf                   : "#{cvars.cache2-url}/local/raf.js"
  reactivejs            : "#{cvars.cache-url}/local/reactive.js"
  socketio              : "#{cvars.cache4-url}/socket.io/socket.io.js"
  powerbulletin         : "#{cvars.cache-url}/powerbulletin#{if process.env.NODE_ENV is \production then '.min' else ''}.js"
  powerbulletin-sales   : "#{cvars.cache-url}/powerbulletin-sales#{if process.env.NODE_ENV is \production then '.min' else ''}.js"
