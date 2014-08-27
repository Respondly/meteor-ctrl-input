days = [
  'mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'
  'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'
]





###
Parses the date in a textbox.
###
class Ctrls.TextboxDate
  ###
  Constructor
  @param textbox: The text-input control.
  ###
  constructor: (@textbox, options = {}) ->
    @textbox.maxLength(30) unless @textbox.maxLength()?



  ###
  REACTIVE: Gets the current date value.
  @param options:
            - setTime:      Flag indicating if the current time should be set if no time was specified.
                            Default: true
  ###
  date: (options = {}) ->
    text = @text()
    try
      # Parse the date.
      date = parse(text)
      return null unless date?

      # Set the time unless a time value was specified.
      if options.setTime ? true
        unless @isTimeSpecified()
          now = new Date()
          hour = now.getHours()
          minute = now.getMinutes()
          date.set(hour:hour, minute:minute)

      # Finish up.
      date

    catch err
      null # Supress parse errors.



  ###
  REACTIVE: Gets or sets the current text.
  ###
  text: (value) -> @textbox.text(value)



  ###
  REACTIVE: Gets whether the textbox contains an "am" or "pm" value.
  ###
  isTimeSpecified: ->
    text = @text()
    return true if text.has(/am/gi) or text.has(/pm/gi)
    return true if text.has(/min/gi) or text.has(/hour/gi) or text.has(/sec/gi)
    false






# PRIVATE --------------------------------------------------------------------------


parse = (text) ->
  # Setup initial conditions.
  text = text.toLowerCase().trim()

  tryParse = (result = {}) ->
      isValid = (value) ->
            date = Date.create(value)
            if date.isValid()
              result.date = date
              true
            else
              false

      startsWith = (values, prefixes...) ->
          values.any (item) ->
                if prefixes.length is 0
                  return text.startsWith(item)
                else
                  for prefix in prefixes
                    return true if text.startsWith(prefix + item)
                  false

      # Orient toward future ("next") when a single day is specified.
      #     This changes from default Sugar behavior of turning "mon"
      #     into the closest monday in the past.
      text = "next #{ text }" if startsWith(days)

      # Now that we are orienting single day values to the future ("next")
      # make "last" mean the most recent specified day.
      if startsWith(days, 'last', 'last ')
        text = text.remove(/^last/).trim()
        text = "this #{ text }"

      # Attempt to parse the date.
      return if isValid(text)
      return if isValid("#{ text } from now")


  result = { date:null }
  tryParse(result)
  result.date




