###
Binds changes between a model and a UI control.
###
class Ctrls.DataBinder extends AutoRun
  ###
  Constructor.
  @param ctrl:            The UI control.
  @param ctrlPropName:    The name of the property-function on the UI control.
  @param modelPropName:   Name of the property-function.
  @param modelFactory:    Function that retrieves the model.
  ###
  constructor: (@ctrl, @ctrlPropName, @modelPropName, @modelFactory) ->
    super
    isInitialized = false

    syncCtrlWithModel = =>
          return unless isInitialized
          if model = @model()
            # Calculate the to/from values.
            to = model.changes()?[@modelPropName]?.to ? @readModelProp()
            from = Deps.nonreactive => @readCtrlProp()

            # Determine whether the UI control should be updated.
            updateCtrl = (to isnt from) # and not @ctrl.hasFocus()
            updateCtrl = true if not isInitialized

            # Perform the update.
            if updateCtrl
              if (@readCtrlProp() isnt to) or not isInitialized
                @writeCtrlProp(to)

    # SYNC: Update the UI control when the saved model property is updated.
    @autorun =>
          model = @model() # Hook into reactive callback.
          syncCtrlWithModel()

    # SYNC: Model reverts.
    @autorun =>
          model = @model() # Hook into reactive callback.
          if model
            if model.isSubModel() and model.parentModel?
              # NB: Hook into parent model if this is a sub-model.
              #     This ensures reactive changes invoke the callback.
              model = model.parentModel

            if model.changes() is null
              # The changes have been reset, sync the control.
              syncCtrlWithModel()

    # Finish up.
    isInitialized = true
    syncCtrlWithModel()



  ###
  The model being synced.
  ###
  model: -> @modelFactory()


  ###
  Gets the property on model.
  ###
  readModelProp: -> @model()[@modelPropName]()


  ###
  Sets the property on model.
  ###
  writeModelProp: (value) ->
    if value is undefined
      @model()[@modelPropName].delete()
    else
      @model()[@modelPropName](value)


  ###
  Gets the property on UI control.
  ###
  readCtrlProp: -> @ctrl[@ctrlPropName]()


  ###
  Write the value to the UI control.
  ###
  writeCtrlProp: (value) ->
    propFunc = @ctrl[@ctrlPropName]
    if value is undefined
      unless Object.isFunction(propFunc.delete)
        throw new Error("Cannot set property '#{ @ctrlPropName }' to undefined, there is no delete method.")
      propFunc.delete()
    else
      propFunc(value)





  ###
  Invoked by the UI control when it's value changes.
  @param toValue: The new value that the control has changed to.
  ###
  onCtrlChanged: (toValue) ->
    # Update the model when the UI control changes.
    @writeModelProp(toValue)

