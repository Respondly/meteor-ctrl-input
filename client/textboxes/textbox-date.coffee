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
  constructor: (@textbox) ->
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
    return false if Util.isBlank(text)
    return true if text.has(/am/gi) or text.has(/pm/gi)
    return true if text.has(/min/gi) or text.has(/hour/gi) or text.has(/sec/gi)
    false






# PRIVATE --------------------------------------------------------------------------


parse = (text) ->
  # Setup initial conditions.
  text = text.toLowerCase().trim()

  tryParse = (result = {}) ->
      isValid = (value) ->
            date = Date.future(value)
            if date.isValid()
              result.date = date
              true
            else
              false


      # Attempt to parse the date.
      return if isValid(text)
      return if isValid("#{ text } from now")


  result = { date:null }
  tryParse(result)
  result.date




