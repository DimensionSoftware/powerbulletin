# this library exists to wrap the silliness of this nodejs library

# repl example of simplified api (vcc is this module):
# livescript> vcc '4000000000000002'
# { type: 'visa',
#   luhn_valid: true,
#   length_valid: true }
# livescript> vcc '5100000000000008'
# { type: 'mastercard',
#   luhn_valid: true,
#   length_valid: true }

require! \cc-validator-node

# singleton-ish
cc-validator = new cc-validator-node

# the silly library uses callbacks in a pure context
# oh well whatever, lets just gloss over that here and
# return to purity-land! =D
module.exports = (num) ->
  var rval
  cc-validator.validate num, (res) ->
    rval := res
  return rval
