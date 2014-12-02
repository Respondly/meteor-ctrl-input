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
    @isInitialized = false

    # setup model change autoruns for the databinder
    @connectAutoRuns()

    # If the model.id changes stop the current set
    # of autoruns and start a new set
    currentId = undefined
    @autorun =>
      @modelFactory() # react to model factory changes
      Deps.nonreactive =>
        # initialize - mark the current model id
        # as the currently bound id
        modelId = @modelId(@model())
        if not currentId and modelId
          currentId = modelId

        # if the current model has changed
        # stop and restart the autoruns
        else if modelId and currentId isnt modelId
          @modelRevertHandle?.stop()
          @modelUIHandle?.stop()
          @connectAutoRuns()
          currentId = modelId

    # Finish up.
    @isInitialized = true
    @syncCtrlWithModel()



  ###
  Sync the model and the ctrl
  ###
  syncCtrlWithModel: ->
    return unless @isInitialized
    if model = @model()
      # Calculate the to/from values.
      to = model.changes()?[@modelPropName]?.to ? @readModelProp()
      from = Deps.nonreactive => @readCtrlProp()

      # Determine whether the UI control should be updated.
      updateCtrl = (to isnt from) # and not @ctrl.hasFocus()
      updateCtrl = true if not @isInitialized

      # Perform the update.
      if updateCtrl
        if (@readCtrlProp() isnt to) or not @isInitialized
          @writeCtrlProp(to)



  ###
  Connect autoruns that are responsible for keeping the model in sync
  with the control
  ###
  connectAutoRuns: ->
    # SYNC: Update the UI control when the saved model property is updated.
    @modelUIHandle = @autorun =>
      model = @model() # Hook into reactive callback.
      @syncCtrlWithModel()

    # SYNC: Model reverts.
    @modelRevertHandle = @autorun =>
      model = @model() # Hook into reactive callback.
      if model
        if model.isSubModel() and model.parentModel?
          # NB: Hook into parent model if this is a sub-model.
          #     This ensures reactive changes invoke the callback.
          model = model.parentModel

        if model.changes() is null
          # The changes have been reset, sync the control.
          @syncCtrlWithModel()



  ###
  The model being synced.
  ###
  model: -> @modelFactory()



  ###
  Return the model id
  Or if the model is a subModel, the parent model
  ###
  modelId: (model) ->
    if model?.id?
      model.id
    else if model?.parentModel?.id
      @modelId(model.parentModel)
    else
      null


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

