###
A single <option> within a <select>.
###
Ctrl.define
  'c-select-option':
    api:
      isSelected: (value) -> @prop 'isSelected', value, default:false


    helpers:
      selected: -> 'selected' if @api.isSelected()
      label: ->
        label = @data.label
        label = @data.value if not label?
        label = '<undefined>' if label is undefined
        label = '<null>' if label is null
        label = 'True' if label is true
        label = 'False' if label is false
        label


      value: ->
        value = @data.value
        value = '<undefined>' if value is undefined
        value = '<null>' if value is null
        value = '<true>' if value is true
        value = '<false>' if value is false
        value = @helpers.label() unless value?
        value

