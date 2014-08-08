
module.exports =
  configDefaults:
    selectAllTagContent: false
    patterns:
      erb: ['<%','%>']
      php: ['<?','?>']

  activate: (state) ->
    patterns = atom.config.get('smart-tag-cycle.patterns')

    @registerCommandsForPattern(k,v) for k,v of patterns

  deactivate: ->

  registerCommandsForPattern: (name, args) ->
    atom.workspaceView.command "smart-tag-cycle:#{name}", @buildCommand(args)
    atom.workspaceView.command "smart-tag-cycle:#{name}-backward", @buildCommand(args, true)

  buildCommand: ([prefix, suffix], backward=false) -> =>
    regex = ///#{prefix}.*?#{suffix}///g

    editor = atom.workspace.getActiveEditor()
    matches = @scanEditor(editor, regex)

    if (index = @cursorInMatches(editor, matches))?
      if backward
        @cycleToPreviousMatch({editor, prefix, suffix, matches, index})
      else
        @cycleToNextMatch({editor, prefix, suffix, matches, index})
    else
      @insertAtCursor({editor, prefix, suffix})

  scanEditor: (editor, regex) ->
    results = []
    editor.scan regex, (result) -> results.push result
    results

  insertAtCursor: ({editor, prefix, suffix}) ->
    cursor = editor.getCursorBufferPosition()
    editor.insertText(prefix + ' ' + suffix)
    editor.setCursorBufferPosition([cursor.row, cursor.column + prefix.length])

  cursorInMatches: (editor, matches) ->
    cursor = editor.getCursorBufferPosition()
    return i for match,i in matches when match.range.containsPoint(cursor)

    null

  cycleToNextMatch: ({editor, prefix, suffix, matches, index}) ->
    nextIndex = index + 1
    nextIndex = 0 if nextIndex >= matches.length

    @moveToMatch({editor, prefix, suffix, match: matches[nextIndex].range})

  cycleToPreviousMatch: ({editor, prefix, suffix, matches, index}) ->
    previousIndex = index - 1
    previousIndex = matches.length - 1 if previousIndex < 0

    @moveToMatch({editor, prefix, suffix, match: matches[previousIndex].range})

  moveToMatch: ({editor, match, prefix, suffix}) ->
    if atom.config.get 'smart-tag-cycle.selectAllTagContent'
      cursorStart = match.start
      cursorEnd = match.end
      editor.setSelectedBufferRange([
        [cursorStart.row, cursorStart.column + prefix.length]
        [cursorEnd.row, cursorEnd.column - suffix.length]
      ])
    else
      cursor = match.start
      editor.setCursorBufferPosition([
        cursor.row
        cursor.column + prefix.length
      ])
