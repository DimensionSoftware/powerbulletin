require! stripe

export init = ->
  console.log 'initializing stripe client'
  console.log JSON.stringify(cvars.stripe)
  export client = stripe cvars.stripe.private-key

# example...
# works in test mode
export test = ->
  pay.client.charges.create {
    amount: 50
    currency: \USD
    description: 'mr clifton collector cap'
    card:
      number: '4242424242424242'
      exp_month: 12
      exp_year: 2014
      cvc: 123
  }, console.log
