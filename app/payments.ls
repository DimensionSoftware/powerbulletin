require! stripe

export init = ->
  console.log 'initializing stripe client'
  console.log JSON.stringify(cvars.stripe)
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
initial-purchase = (site-id, product-id, card, cb) ->
  err, res <~ db.sites.find-one {
    criteria: {id: site-id}
    columns: [\user_id]
  }
  if err then return cb err
  unless user-id = res.user_id
    throw new Error "the site must have an owner to subscribe"

  err <~ db.add-subscription site-id, product-id
  if err then return cb err

  err, total-monthly-cost <~ db.subscription-total user-id
  if err then return cb err

  stripe-cust-info = {
    plan: \plan
    quantity: total-monthly-cost
    card
  }

  err, customer <- @client.customers.create stripe-cust-info
  if err then return cb err

  err <- db.users.update {criteria: {id: user-id}, data: {stripe_id: customer.id}}
  if err then return cb err

  cb null, customer

subsequent-purchase = (site-id, product-id, cb) ->
  # infer owner (user-id) from site-id
  # needs to update subscription (and qty) on stripe side

# in repl: pay.purchase 1, 1, pay.test-card, cl
export purchase = (user-id, product-id, card, cb) ->
  initial-purchase.call(@, user-id, product-id, card, cb)
