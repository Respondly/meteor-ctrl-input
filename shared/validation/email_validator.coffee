###
A validator that evaluates regular expressions.
###
class Ctrls.EmailValidator
  constructor: (@email, @invalidDomains = [] ) ->
    isValid: undefined
    message: null
    @validate(@email) if @email?


  ###
  Determines whether the given value is valid.
  @param email: The value to validate.
  @returns true if the value conforms, otherwise false.
  ###
  validate: (email) ->
    # Setup initial conditions.
    invalid = (message = null) =>
      @isValid = false
      @message = message
      false

    return invalid('Email not specified.') unless Object.isString(email)

    # Ensure there is an '@' symbol.
    unless email.has /@/
      return invalid("Email address must have an @ symbol.")

    # Split on the '@'.
    parts  = email.split('@')
    name   = parts[0]
    domain = parts[1]?.toLowerCase()

    return invalid("Email address has too many @ symbols.") unless parts.length is 2
    return invalid("Email address does not have a name.") if name.isBlank()
    return invalid("Email address does not have a domain.") if domain.isBlank()

    # Ensure there is a domain.
    unless domain.has /.+\..+/i
      return invalid("Domain name is not complete.")

    if /\s/g.test(domain)
      return invalid("Domain name cannot contain spaces.")

    if /\s/g.test(name)
      return invalid("Name cannot contain spaces.") # rejected by Gmail

    if @invalidDomains && @invalidDomains.indexOf(domain) >= 0
      return invalid("An email address at #{domain} can't be used.")

    # Finish up.
    @isValid = true
    @message = null
    true
