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
        label


      value: ->
        value = @data.value
        value = @helpers.label() unless value?
        value

