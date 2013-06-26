# this module is to coordnate all client-side dependencies
# so if we update it in one spot it updates in all spots...
#
# assumes cvars is present
module.exports =
  #jquery-fancybox: "#{cvars.cache2-url}/fancybox/jquery.fancybox.css?#{global.CHANGESET}"
  master-sales: "/dynamic/css/master-sales.styl?#{global.CHANGESET}"
