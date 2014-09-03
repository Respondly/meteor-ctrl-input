Ctrl.define
  ###
  A raw-text input control.

  Events:
    - changed
    - keydown
    - keyup

    - blur
    - focus

    - key:enter:  The enter key was pressed.
    - key:esc:    The escape key was pressed.

  ###
  'c-raw-textbox':
    ready: ->
      # Setup initial conditions.
      @api.text(@defaultValue('text') ? @helpers.sessionText())


      # Sync: Text.
      @autorun =>
          # Read value.
          text = @api.text()

          # Ensure it's less than the max-length.
          maxLength = @api.maxLength()
          if Object.isNumber(maxLength)
            if text.length > maxLength
              @api.text(text.first(maxLength))
              return

          # Store in session.
          Deps.nonreactive => @helpers.sessionText(text)

          # Alert listeners.
          @trigger('changed', { text:text }) if @isCreated

      # Sync: CSS.
      @autorun =>
          el        = @find()
          isEnabled = @api.isEnabled()
          canEdit   = @api.canEdit()

          el.toggleClass 'c-border', @api.border()
          el.toggleClass 'c-enabled', isEnabled
          el.toggleClass 'c-disabled', not isEnabled
          el.toggleClass 'c-can-edit', canEdit
          el.toggleClass 'c-cannot-edit', not canEdit

          # Sizes.
          for className in el.attr('class').split(' ')
            if className.startsWith('c-size-')
              el.removeClass(className)
          el.addClass("c-size-#{ @api.size() }")

      # Sync: Disabled state.
      @autorun =>
          @api.multiLine() # Hook into reactive callback.
          el = @helpers.elTextBox()
          DISABLED = 'disabled'
          if @api.isEnabled() and @api.canEdit()
            el.removeAttr(DISABLED)
          else
            el.attr(DISABLED, DISABLED)




    api:
      # Properties --------------------------------------------------------------------------

      ###
      REACTIVE: The text value.
      ###
      text: (value) ->
        if value isnt undefined
          el = @helpers.elTextBox()
          el.val(value) unless el.val() is value
        @prop 'text', value


      ###
      REACTIVE: Gets or sets the enabled state of the textbox.
      ###
      isEnabled: (value) -> @prop 'isEnabled', value, default:true

      ###
      REACTIVE: Gets or sets whether the textbox is in an editable state (changes display state).
      ###
      canEdit: (value) -> @prop 'canEdit', value, default:true

      ###
      REACTIVE: Flag indicating if multiple lines can be entered.
      ###
      multiLine: (value) -> @prop 'multiLine', value, default:true

      ###
      REACTIVE: Gets or sets the maximum number of characters that can be typed into the textbox.
      ###
      maxLength: (value) -> @prop 'maxLength', value, default:null

      ###
      REACTIVE: Flag indicating if the text is selected upon recieving focus.
      ###
      selectOnFocus: (value) -> @prop 'selectOnFocus', value, default:false

      ###
      REACTIVE: Flag indicating whether the textbox renders a border.
      ###
      border: (value) -> @prop 'border', value, default:true

      ###
      REACTIVE: Gets or sets a number indicating the display size.
      ###
      size: (value) -> @prop 'size', value, default:1


      ###
      REACTIVE: Gets the length of the current text value.
      ###
      length: -> @api.text().length


      ###
      REACTIVE: Gets whether the textbox has no text.
      ###
      isEmpty: -> @api.length() is 0


      ###
      REACTIVE: Gets whether the textbox is blank (strips whitespace and last char-return).
      ###
      isBlank: ->
        text = @api.text()
        return true if APP.isBlank(text)
        return true if text.trim() is '\n'
        false


      ###
      REACTIVE: Gets or sets the scroll-height of the control.
      ###
      scrollHeight: ->
        el = @helpers.elTextBox()[0]
        prop = (value) => @prop 'scroll-height', value, default:el?.scrollHeight
        if el
          prop(el.scrollHeight)
        prop() # Hook into reactive context.


      ###
      REACTIVE: Gets or sets whether the text content is overflowing the available space within the textbox.
      ###
      isOverflowing: ->
        prop = (value) => @prop 'overflowing', value, default:false
        el = @helpers.elTextBox()[0]
        if el
          prop(el.offsetHeight < el.scrollHeight)
        prop() # Hook into reactive context.



      # Methods --------------------------------------------------------------------------


      ###
      Assigns focus to the textbox.
      ###
      focus: -> @helpers.elTextBox().focus()


      ###
      Determines whether the textbox currently has focus.
      ###
      hasFocus: -> @helpers.elTextBox()[0] is document.activeElement


      ###
      Selects all the text within the textbox.
      ###
      selectAll: -> @helpers.elTextBox().select()

      ###
      Move the selection caret to the end of the text.
      ###
      caretToEnd: -> @helpers.elTextBox().caretToEnd()


      ###
      Moves the selection caret to the specified index.
      ###
      caretTo: (index) -> @helpers.elTextBox().caret(index)


      ###
      Clears the textbox.
      ###
      empty: -> @api.text('')


      ###
      Alias for 'empty'.
      ###
      clear: -> @api.empty()




    helpers:
      cssClass: -> @defaultValue('cssClass')
      multiLine: -> @api.multiLine()
      sessionText: (value) -> @session().prop 'text', value, default:''

      elTextBox: ->
        selector = if @api.multiLine() then 'textarea' else 'input'
        @find(selector)


      # Event Handlers ----------------------------------------------------------------------


      onKeyDown: (e) ->
        e = Util.keys.toArgs(e)

        # Prevent the input going over the maximum length.
        maxLength = @api.maxLength()
        if Object.isNumber(maxLength) and e.isContentKey()
          if @api.length() >= maxLength
            return e.cancel()

        # Alert listeners.
        @trigger('keydown', e)

      onKeyUp: (e) ->
        @api.text($(e.target).val())
        e = Util.keys.toArgs(e)
        @trigger('keyup', e)
        @trigger('key:enter', e) if e.is.enter
        @trigger('key:esc', e) if e.is.esc

      onBlur: (e) -> @trigger 'blur'
      onFocus: (e) ->
        @trigger 'focus'
        if @api.selectOnFocus()
          Deps.afterFlush => @api.selectAll()



    events:
      'keydown textarea': (e) -> @helpers.onKeyDown(e)
      'keydown input': (e) -> @helpers.onKeyDown(e)

      'keyup textarea': (e) -> @helpers.onKeyUp(e)
      'keyup input': (e) -> @helpers.onKeyUp(e)

      'focus textarea': (e) -> @helpers.onFocus(e)
      'focus input': (e) -> @helpers.onFocus(e)

      'blur textarea': (e) -> @helpers.onBlur(e)
      'blur input': (e) -> @helpers.onBlur(e)



