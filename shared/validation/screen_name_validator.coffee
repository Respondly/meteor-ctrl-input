###
A validator that evaluates regular expressions.
###
class Ctrls.TwitterScreenNameValidator
  constructor: (@screenName) ->
    isValid: undefined
    message: null
    @validate(@screenName) if @screenName?


  ###
  Determines whether the given value is valid.
   @param screenName: The value to validate.
  @returns true if the value conforms, otherwise false.
  ###
  validate: (screenName) ->
    invalid = (message = null) =>
      @isValid = false
      @message = message
      false

    # Setup initial conditions.
    screenName ?= ''
    return invalid() if screenName.isBlank()

    # Ensure the name is not too long.
    return invalid('Must be less than 15 characters.') if screenName.length > 15

    # Ensure the name only contains letters/numbers and the underscore (_) character.
    match = screenName.match /(^@)?[A-Za-z0-9_]*/g
    match = match[0]
    unless match is screenName
      return invalid('Only letters, numbers or underscores.')

    # Finish up.
    @message = null
    @isValid = true
    true

