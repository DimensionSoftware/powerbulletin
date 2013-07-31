# this module is to coordnate all client-side dependencies
# so if we update it in one spot it updates in all spots...
#
# assumes cvars is present
module.exports =
  jquery                : "#{cvars.cache-url}/local/jquery-1.9.1.min.js"
  jquery-cookie         : "#{cvars.cache3-url}/local/jquery.cookie-1.3.1.min.js"
  jquery-history        : "#{cvars.cache5-url}/local/history.min.js"
  jquery-html5-uploader : "#{cvars.cache2-url}/local/jquery.html5uploader.js"
  jquery-masonry        : "#{cvars.cache4-url}/local/jquery.masonry.min.js"
  jquery-nicescroll     : "#{cvars.cache5-url}/local/jquery.nicescroll.min.js"
  jquery-sceditor       : "#{cvars.cache-url}/local/jquery.sceditor.bbcode.min.js"
  jquery-transit        : "#{cvars.cache2-url}/local/jquery.transit-0.9.9.min.js"
  jquery-ui             : "#{cvars.cache3-url}/local/jquery-ui.min.js"
  jquery-waypoints      : "#{cvars.cache4-url}/local/waypoints.min.js"
  raf                   : "#{cvars.cache5-url}/local/raf.js"
  reactivejs            : "#{cvars.cache-url}/local/reactive.js"
  powerbulletin         : "#{cvars.cache3-url}/powerbulletin#{if process.env.NODE_ENV is \production then '.min' else ''}.js"
  powerbulletin-sales   : "#{cvars.cache4-url}/powerbulletin-sales#{if process.env.NODE_ENV is \production then '.min' else ''}.js"
