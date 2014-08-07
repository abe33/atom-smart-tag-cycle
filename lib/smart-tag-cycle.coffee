
module.exports =
  configDefaults:
    patterns:
      erb: ['<%','%>']

  activate: (state) ->
    patterns = atom.config.get('smart-tag-cycle.patterns')

    @registerCommandForPattern(k,v) for k,v of patterns

  deactivate: ->

  registerCommandForPattern: (name, args) ->
    atom.workspaceView.command "smart-tag-cycle:#{name}", @buildCommand(args)
    atom.workspaceView.command "smart-tag-cycle:#{name}-backward", @buildCommand(args, true)

  buildCommand: ([prefix, suffix], backward=false) -> =>
    regex = ///#{prefix}.*?#{suffix}///g

    editor = atom.workspace.getActiveEditor()
    matches = @scanEditor(editor, regex)

    if (index = @cursorInMatches(editor, matches))?
      if backward
        @cycleToPreviousMatch(editor, prefix, matches, index)
      else
        @cycleToNextMatch(editor, prefix, matches, index)
    else
      @insertAtCursor(editor, prefix, suffix)

  scanEditor: (editor, regex) ->
    results = []
    editor.scan regex, (result) -> results.push result
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

  cycleToPreviousMatch: (editor, prefix, matches, i) ->
    nextIndex = i - 1
    nextIndex = matches.length - 1 if nextIndex < 0

    cursor = matches[nextIndex].range.start
    editor.setCursorBufferPosition([cursor.row, cursor.column + prefix.length])
