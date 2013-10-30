# each exports item represents a product id, and takes one argument:
# a site id
# meant to only be used server-side, not on client
@private = (site-id, cb = (->)) ->
  # update site config and mark private

  err, site <- db.site-by-id site-id
  if err then return cb err

  site.config.private = true

  err <- db.site-update site
  if err then return cb err

  console.warn \private, \purchased, site-id

  cb!

@custom_domain = (site-id, cb = (->)) ->
  console.warn \custom_domain, \purchased
  cb!

@compute_instance = (site-id, cb = (->)) ->
  console.warn \compute_instance, \purchased
  cb!

@analytics = (site-id, cb = (->)) ->
  console.warn \analytics, \purchased
  cb!
