# this module is to coordnate all client-side dependencies
# so if we update it in one spot it updates in all spots...
#
# assumes cvars is present
module.exports =
  #jquery-fancybox: "#{cvars.cache2-url}/fancybox/jquery.fancybox.css?#{global.CHANGESET}"
  master-sales:
    if process.env.NODE_ENV is \production
      "#{cvars.cache2-url}/master-sales.css?#{global.CHANGESET}"
    else
      "/dynamic/css/master-sales.styl?#{global.CHANGESET}"
