
module.exports =
  configDefaults:
    patterns:
      erb: ['<%','%>']

  activate: (state) ->
    patterns = atom.config.get('smart-tag-cycle.patterns')

    @registerCommandForPattern(k,v) for k,v of patterns

  deactivate: ->

  registerCommandForPattern: (name, [prefix, suffix]) ->
    regex = ///#{prefix}.*?#{suffix}///g

    atom.workspaceView.command "smart-tag-cycle:#{name}", =>
      editor = atom.workspace.getActiveEditor()
      matches = @scanEditor(editor, regex)

      console.log editor.getText(), matches

      if (index = @cursorInMatches(editor, matches))?
        console.log index
        @cycleToNextMatch(editor, prefix, matches, index)
      else
        @insertAtCursor(editor, prefix, suffix)

  scanEditor: (editor, regex) ->
    results = []
    console.log regex
    editor.scan regex, (result) ->
      results.push result
      console.log 'in iterator'
    results

  insertAtCursor: (editor, prefix, suffix) ->
    cursor = editor.getCursorBufferPosition()
    editor.insertText(prefix + ' ' + suffix)
    editor.setCursorBufferPosition([cursor.row, cursor.column + prefix.length])

  cursorInMatches: (editor, matches) ->
    cursor = editor.getCursorBufferPosition()
    return i for match,i in matches when match.range.containsPoint(cursor)

    null

  cycleToNextMatch: (editor, prefix, matches, i) ->
    nextIndex = i + 1
    nextIndex = 0 if nextIndex >= matches.length

    cursor = matches[nextIndex].range.start
    editor.setCursorBufferPosition([cursor.row, cursor.column + prefix.length])
