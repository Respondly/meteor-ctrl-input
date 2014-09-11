###
Convert HTML from contenteditable areas to text

    This method takes care to replace <br>'s entered from shift-enter
    to normal <p> blocks.
    It uses the text we get out of the mediumeditor controls,
    so may or may not be appropriate for general use.

###
PKG.htmlToText = (html) ->
  return '' unless html?

  # Approach for handling <br> tags is to split on them, process the text, then join with </p><p>
  htmlLines = html.split('<br>')
  newHtmlLines = []
  previousLine = ''

  for htmlLine in htmlLines
    # An empty line occurs when there where multiple <br>'s in a row. Normalize each to <p><br></p> effectively
    if htmlLine == ''
      newHtmlLines[newHtmlLines.length - 1 ] = newHtmlLines[newHtmlLines.length - 1 ] + '</p><p><br>'
    else
      if htmlLine.startsWith('</p>')
        if previousLine.endsWith('<p>')
          # If this <br> split occurred on <p><br></p>, then keep the new line
          newHtmlLines[newHtmlLines.length - 1 ] = newHtmlLines[newHtmlLines.length - 1 ] + '<br>' + htmlLine
        else
          # If this <br> split occurred on 'xyz<br></p>, then ignore the <br> as it's not rendered
          # This can occurred in firefox, or in chrome if a combo of shift-enter + enter is used.
          newHtmlLines[newHtmlLines.length - 1 ] = newHtmlLines[newHtmlLines.length - 1 ] + htmlLine
      else
        # <br> was in the middle of content - add the content after it as a new line.
        newHtmlLines.push htmlLine
    previousLine = htmlLine

  # Rejoin the processed lines with </p><p> tags to reform correct paragraphs
  html = newHtmlLines.join('</p><p>')

  pre = $('<pre>').html(html)
  pre.find('p').replaceWith -> @innerHTML + '\n'
  text = pre.text()
  text = text.first(text.length - 1) if text.last() is '\n'
  text