# each exports item represents a product id, and takes one argument:
# a site id
# meant to only be used server-side, not on client
@private = (site-id, cb = (->)) ->
  # update site config and mark private

  err, config <- db.sites.find-one {criteria: {id: site-id}, columns: [\config]}
  if err then return cb err

  config.private = true

  err <- db.sites.update {criteria: {id: site-id}, data: {config: JSON.stringify(config)}}
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
