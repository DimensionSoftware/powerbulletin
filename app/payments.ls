require! stripe
require! \./on-purchase
require! h:\./server-helpers

export client = stripe cvars.stripe.private-key

export test-card =
  number: '4242424242424242'
  exp_month: 12
  exp_year: 2014
  cvc: 123

# example...
# works in test mode
export test = ->
  pay.client.charges.create {
    amount: 50
    currency: \USD
    description: 'mr clifton collector cap'
    card: @test-card
  }, console.log

# NOTE: need to verify yourself whether said can purchase for this site
export subscribe = ({
  site-id = void
  product-id = void
  card = void
} = {}, cb = (->)) ->
  unless site-id
    return cb new Error "siteId is required to subscribe"

  err, product <~ db.products.select-one id: product-id
  if err then return cb err
  unless product
    return cb new Error "Subscription requires a valid product"

  err, res <~ db.site-by-id site-id
  if err then return cb err
  unless user-id = res?user_id
    return cb new Error "Site must have an owner to subscribe"

  err, total-monthly-cost <~ db.subscription-total user-id
  if err then return cb err
  console.log {user-id, total-monthly-cost}
  total-monthly-cost += product.price
  console.log {user-id, new-total-monthly-cost: total-monthly-cost}

  subscription = {
    plan: \plan
    quantity: total-monthly-cost
  }
  subscription <<< {card} if card

  err, res <~ db.users.select-one id: user-id
  if err then return cb err
  if stripe-id = res.stripe_id
    err <- @client.customers.update_subscription stripe-id, subscription
    if err then return cb err

    err <- db.add-subscription site-id, product-id
    if err then return cb err

    cb!
  else
    err, customer <- @client.customers.create subscription
    if err then return cb err

    err <- db.users.update { stripe_id: customer.id }, { id: user-id }
    if err then return cb err

    err <- db.add-subscription site-id, product-id
    if err then return cb err

    # send notificaiton email to sales person
    email =
      from    : \conversion.tunnel.o.matic@powerbulletin.com
      to      : \sales@powerbulletin.com
      subject : "new subscription was just purchased (#{product-id})"
      text    : "new subscription was just purchased (#{product-id}). site-id: #{site-id}"
    err <- h.send-mail email
    if err then return cb err

    # execute purchase hooks
    console.log "Executing on-purchase hooks for product: #{product-id}"
    unless on-purchase[product-id] then return cb err # guard if no hook
    err <- on-purchase[product-id] site-id
    if err then return cb err

    cb!
