CONTENT_EDITABLE = 'contenteditable'
BLANK_LINE = '<p><br></p>'

isFirefox = null
isIE = null

###
Wraps a content-editable textbox providing a consistent/reactive API.

Events:
  - keydown
  - keyup
  - changed

  - blur
  - focus

  - key:enter:  The enter key was pressed.
  - key:esc:    The escape key was pressed.

###
class Ctrls.ContentEditable extends AutoRun
  ###
  Constructor.
  @param id:            The unique ID of the textbox.
  @param el:            The [contenteditable] element under control.
  @param parentSession: (optional) The parent session object to use.
  ###
  constructor: (@id, parentSession) ->
    # Setup initial conditions.
    super
    @hash = new ReactiveHash()
    @id ?= _.uniqueId('txt-')
    if parentSession
      @session = parentSession.createChild(@id)
    else
      @session = new ScopedSession(@id)

    # Extend with event methods.
    Util.Events.extend(@)

    # Finish up.
    isFirefox ?= UserAgent.current.isFirefox()
    isIE ?= UserAgent.current.isIE()



  ###
  Disposes of the textbox.
  ###
  dispose: ->
    super
    @session.dispose()
    @hash.dispose()
    @blur()



  ###
  Initializes the textbox with an element.
  NB: This is useful if creating the textbox within an 'init' function of a control
      so that values can be reactive bound to, before the actual element is created in the DOM.
  ###
  init: (el) ->
    # Setup initial conditions.
    return unless el
    @el = el
    el.addClass 'c-content-editable'

    # Wire up events.
    bubble = (eventName, e) => @trigger eventName, e


    # Sync: Editable and enabled states.
    @autorun =>
          canEdit   = @canEdit()
          isEnabled = @isEnabled()

          # CSS Classes.
          @el.toggleClass 'can-edit', canEdit
          @el.toggleClass 'cannot-edit', not canEdit

          @el.toggleClass 'is-enabled', isEnabled
          @el.toggleClass 'disabled', not isEnabled

          # Update 'content-editable' attribute.
          # Only update it if changed from DOM.
          canEdit = false if isEnabled is false
          domValue = Util.isTrue(@el.attr(CONTENT_EDITABLE))
          @el.attr(CONTENT_EDITABLE, canEdit) if canEdit isnt domValue


    # Create the rich-text formatter.
    mediumEditor = new INTERNAL.MediumEditor el[0],
          placeholder: ''
          cleanPastedHTML:  false
          forcePlainText:   true
          delay:            100
          firstHeader:      'h1'
          secondHeader:     'h2'
          buttons:          [
                              'bold'
                              'italic'
                              'anchor'
                              'header1'
                              'header2'
                              'quote'
                              'unorderedlist'
                              'orderedlist'
                              'indent'
                              'outdent'
                            ]

    # Sync rich-formatting controller.
    @autorun =>
          options = mediumEditor.options

          # Determine whether the formatting toolbar should be disabled.
          disableToolbar = @isPlainText()
          disableToolbar = true if not @isEnabled()
          options.disableToolbar = disableToolbar



    KEYS = Const.KEYS
    keyArgs = (e) -> Util.keys.toArgs(e)

    keydownValue = null
    el.keydown (e) =>
        e = keyArgs(e)
        bubble 'keydown', e
        keydownValue = @html()
        cancel = -> e.preventDefault()

        # Ensure the <br> is removed from an empty line (<p><br></p>)
        if isFirefox and APP.core.keys.isContentKey(e)
          anchorNode = document.getSelection().anchorNode
          if anchorNode.outerHTML is BLANK_LINE
            $(anchorNode).children()[0]?.remove()

        # Handle max-length.
        maxLength = @maxLength()
        if maxLength?
          if @length() >= maxLength
            cancel() if APP.core.keys.isContentKey(e)

        # Handle special keys.
        switch e.which
          when KEYS.ENTER then cancel() unless @multiLine is true

        # Supress formatting keys if in "plain-text" mode.
        if @isPlainText()
          isMac = UserAgent.current.isMac()
          switch e.which
            when KEYS.B then cancel() if (isMac and e.metaKey) or (not isMac and e.ctrlKey)
            when KEYS.I then cancel() if (isMac and e.metaKey) or (not isMac and e.ctrlKey)
            when KEYS.U then cancel() if e.ctrlKey # NB: Both mac and PC use the [CTRL + U] combo for underline.


    el.keyup (e) =>
        @html( el.html(), _originalValue:keydownValue )
        e = keyArgs(e)
        bubble 'keyup', e

        # Raise common key-type events.
        switch e.which
          when KEYS.ESC   then bubble 'key:esc', e
          when KEYS.ENTER then bubble 'key:enter', e

    el.blur (e) => bubble 'blur', keyArgs(e)
    el.focus (e) =>
        bubble 'focus', keyArgs(e)
        if @selectOnFocus is true and @canEdit() and @isEnabled()
          unless @text().isBlank()
            @selectAll()


    # Paste AFTER medium-js has handled the paste.
    el.on 'paste', (e) =>
        userAgent = UserAgent.current
        wasChanged = false

        # Ensure multiple lines has not been pasted if not supported.
        if not @multiLine
          text = @text()
          if text.indexOf('\n') > -1
            @text(text.replace(/\n/g, ' '))
            wasChanged = true

        # Ensure result from the paste is not longer than the maxlength.
        text = @text()
        maxLength = @maxLength()
        if Object.isNumber(maxLength)
          if text.length > maxLength
            @text(text.substring(0, maxLength))
            wasChanged = true

        # Windows (IE, Chrome): Remove additional new-line's that come from the paste data on Windows.
        if userAgent.isWindows()
          if userAgent.isIE() or userAgent.isChrome()
            text = ''
            for line, i in @text().lines()
              text += "#{ line }\n" if i.isEven()
            @text(text)

        # Finish up.
        @html(@el.html()) # Ensure the HTML property is up-to-date.
        @caretToEnd() if wasChanged

    # Finish up.
    @updateState()
    @



  # Events.
  onKeydown: (func) -> @el.keydown(func)
  onKeyup:   (func) -> @el.keyup(func)
  onBlur:    (func) -> @el.blur(func)
  onFocus:   (func) -> @el.focus(func)


  ###
  REACTIVE: Gets or sets the HTML in the textbox.
  @param value: Optional - the new value.  Pass nothing to read.
  @param options
            - _originalValue (internal): A value to use to determine if the 'changed' event should fire.
  ###
  html: (value, options = {}) ->

    # Write.
    if value isnt undefined
      if @el
        # Handle empty values.
        value = '' if value is null
        value = value.toString() unless Object.isString(value)

        # Determine if the value is blank.
        isBlank = false
        isBlank = true if value is '<br>'
        isBlank = true if value is '&nbsp;'
        isBlank = true if value is BLANK_LINE
        isBlank = true if Util.isBlank(value)
        value = BLANK_LINE if isBlank

        # Determine whether the 'changed' event should fire.
        originalValue      = options._originalValue ? @el.html()
        fireChanged        = originalValue isnt value
        textDiffersFromDom = toText(value) isnt toText(@el.html())

        # Update the element if the DOM value differs from the value being set here.
        if textDiffersFromDom or (isBlank and @el.html() isnt BLANK_LINE)
          @el.html(value)

          # Ensure the caret is inserted within the blank <p>.
          # Note: This prevents typing in Firefox inserting chars outside of the <p>
          #       after a CMD + A selection has deleted all the content.
          if isFirefox and isBlank and @hasFocus()
            range = document.createRange()
            sel   = window.getSelection()
            range.setStart(@el.children()[0], 0)
            range.collapse(true)
            sel.removeAllRanges()
            sel.addRange(range)

        # Update state.
        @isOverflowing()
        @scrollHeight()

        # Alert listeners.
        @trigger 'changed', { html:value, text:@text() } if fireChanged

        # Re-read the value from the DOM after all write/modifications have occurred.
        # This is used to store in the reactive session property.
        value = @el.html()

    # Read.
    result = @session.prop('html', value)
    result = BLANK_LINE if Util.isBlank(result)
    result



  ###
  REACTIVE: Gets or sets the TEXT content of the textbox.
            NB: This passes through to HTML version of this method.
            If writing, to retain tags use the [html] method.
  ###
  text: (value) ->
    # Setup initial conditions.
    @html() # Hook into reactive context.

    read = => toText(@el?.html())

    # Write.
    if value isnt undefined
      value = '' if value is null
      value = value.toString() unless Object.isString(value)
      if value isnt read()
        value = value.escapeHTML()
        lines = value.lines (line) -> if Util.isBlank(line) then BLANK_LINE else "<p>#{ line }</p>"
        value = lines.join('')
        @html(value)

    # Read.
    read()


  ###
  REACTIVE: Gets or sets whether the textbox is in an editable state.
  ###
  canEdit: (value) -> @hash.prop 'canEdit', value, default:true


  ###
  REACTIVE: Gets or sets the enabled state of the textbox.
  ###
  isEnabled: (value) -> @hash.prop 'isEnabled', value, default:true


  ###
  REACTIVE: Gets or sets whether the control is only pain text (true) or
            supports rich formatting styles (false).
  ###
  isPlainText: (value) -> @hash.prop 'isPlainText', value, default:true


  ###
  Syncs the current state of the DOM with the current data values.
  ###
  updateState: ->
    @canEdit @canEdit()
    @html @html()


  ###
  REACTIVE: Gets the length of the current text value.
  ###
  length: -> @text().length


  ###
  REACTIVE: Gets whether the textbox has no text.
  ###
  isEmpty: -> @length() is 0


  ###
  REACTIVE: Gets whether the textbox is blank (strips whitespace and last char-return).
  ###
  isBlank: ->
    text = @text()
    return true if text.isBlank()
    return true if text.trim() is '\n'
    false


  ###
  Assigns focus to the textbox element.
  ###
  focus: ->
    unless @hasFocus()
      @el?.focus()
      @caretToEnd()


  ###
  Removes focus from the textbox element.
  ###
  blur: -> @el?.blur()


  ###
  Determines whether the textbox currently has focus.
  ###
  hasFocus: -> @el[0] is document.activeElement


  ###
  Flag indicating whether the textbox supports multiple lines.
  ###
  multiLine: true

  ###
  Gets or sets whether the text is selected upon recieving focus.
  ###
  selectOnFocus: false


  ###
  Gets or sets the maximum number of characters that can be typed into the textbox.
  ###
  maxLength: (value) ->
    if value isnt undefined
      value = null if not Object.isNumber(value)
      if value isnt null
        value = null if value < 1
    @hash.prop 'max-length', value, default:null


  ###
  Selects all the text within the textbox.
  ###
  selectAll: -> Deps.afterFlush => @el.selectText()


  ###
  Move the selection caret to the end of the text.
  ###
  caretToEnd: ->
    el = @el.find('p:last-child')[0]
    return unless el

    if document.createRange # Firefox, Chrome, Opera, Safari, IE 9+

      range = document.createRange()             # Create a range (a range is a like the selection but invisible).
      range.selectNodeContents(el)               # Select the entire contents of the element with the range.
      range.collapse(false)                      # Collapse the range to the end point. false means collapse to end rather than the start.
      selection = window.getSelection()          # Get the selection object (allows you to change selection).
      selection.removeAllRanges()                # Remove any selections already made.
      selection.addRange(range)                  # Make the range you have just created the visible selection.

    else # IE 8 and lower.

      range = document.body.createTextRange()    # Create a range (a range is a like the selection but invisible)
      range.moveToElementText(el)                # Select the entire contents of the element with the range
      range.collapse(false)                      # Collapse the range to the end point. false means collapse to end rather than the start
      range.select()                             # Select the range (make it the visible selection




  ###
  Inserts the given text at the current cursor position.

    See: http://jsfiddle.net/Ukkmu/4/

  @param text: The text to insert.
  ###
  insertTextAtCursor: (text) ->
    return if Util.isBlank(text)

    if sel = window.getSelection()
      if (sel.getRangeAt and sel.rangeCount)
        range = sel.getRangeAt(0).cloneRange()
        range.deleteContents()
        textNode = document.createTextNode(text)
        range.insertNode(textNode)

        # Move caret to the end of the newly inserted text node.
        range.setStart(textNode, textNode.length)
        range.setEnd(textNode, textNode.length)
        sel.removeAllRanges()
        sel.addRange(range)

    else
      range = document.selection.createRange()
      range.pasteHTML(text)


  ###
  Clears the textbox.
  ###
  empty: -> @html('')


  ###
  Alias for 'empty'.
  ###
  clear: -> @empty()


  ###
  The parent that this textbox scrolls within.  If null the textbox itself
  is assumed to be scrolling.
  ###
  scrollParent: null


  ###
  REACTIVE: Gets or sets whether the text content is overflowing the available space within the textbox.
  ###
  isOverflowing: ->
    prop = (value) => @hash.prop 'overflowing', value, default:false
    el = if @scrollParent then @scrollParent[0] else @el?[0]
    if el
      prop(el.offsetHeight < el.scrollHeight)
    prop() # Hook into reactive context.


  ###
  REACTIVE: Gets or sets the scroll-height of the control.
  ###
  scrollHeight: ->
    el = @el?[0]
    prop = (value) => @hash.prop 'scroll-height', value, default:el?.scrollHeight
    if el
      prop(el.scrollHeight)
    prop() # Hook into reactive context.



# PRIVATE --------------------------------------------------------------------------



toText = (html) -> INTERNAL.htmlToText(html)

