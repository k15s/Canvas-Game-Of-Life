# The universe of the Game of Life is an infinite two-dimensional
# orthogonal grid of square cells, each of which is in one of two
# possible states, live or dead. Every cell interacts with its eight
# neighbors, which are the cells that are horizontally, vertically, or
# diagonally adjacent. At each step in time, the following transitions
# occur:
#
#   - Any live cell with fewer than two live neighbors dies, as if
#     caused by under-population.
#   - Any live cell with two or three live neighbors lives on to the
#     next generation.
#   - Any live cell with more than three live neighbors dies, as if by
#     overcrowding.
#   - Any dead cell with exactly three live neighbors becomes a live
#     cell, as if by reproduction.
#
# The initial pattern constitutes the seed of the system. The first
# generation is created by applying the above rules simultaneously to
# every cell in the seed -- births and deaths occur simultaneously,
# and the discrete moment at which this happens is sometimes called a
# tick (in other words, each generation is a pure function of the
# preceding one). The rules continue to be applied repeatedly to
# create further generations.
class GameOfLife
  boardSize: 30
  canvasSize: 500
  lineColor: '#e6e6e6'
  liveCellColor: '#ffcc33'
  deadCellColor: '#2e2e2e'

  constructor: ->
    @board = (0 for j in [1...@boardSize + 1] for i in [1...@boardSize + 1])
    @paintBoard()

  runGeneration: ->
    @simulateGeneration()
    @paintBoard()

  clearBoard: ->
    for row in [0...@boardSize]
      for col in [0...@boardSize]
        @board[row][col] = 0

  randPopulateBoard: ->
    for row in [0...@boardSize]
      for col in [0...@boardSize]
        if Math.random() < 0.5  # decimal probability
          @board[row][col] = 1
        else
          @board[row][col] = 0

  simulateGeneration: ->
    toLive = []
    toDie = []
    # We don't set live or dead cells just yet. In each generation we
    # keep track of the changes to make in a list as we iterate
    # through all cells determining how to handle each one.
    for row in [0...@boardSize]
      for col in [0...@boardSize]
        @handleCell(row, col, toLive, toDie)
    for l in toLive
      @board[l[0]][l[1]] = 1
    for l in toDie
      @board[l[0]][l[1]] = 0

  handleCell: (row, col, toLive, toDie) ->
    liveNeighbors = @countLiveNeighbors(row, col)
    if @board[row][col] == 1 && (liveNeighbors < 2 || liveNeighbors > 3)
      toDie.push([row, col])
    else if @board[row][col] == 0 && liveNeighbors == 3
      toLive.push([row, col])

  validCoordinates: (row, col) ->
    if row >= 0 && row < @boardSize && col >= 0 && col < @boardSize
      true
    else
      false

  # Check all 8 neighboring cells of (row,col) cell and determine
  # number of live neighbors
  countLiveNeighbors: (row, col) ->
    count = 0
    if @validCoordinates(row, col + 1) && @board[row][col + 1] == 1
      count += 1
    if @validCoordinates(row - 1, col) && @board[row - 1][col] == 1
      count += 1
    if @validCoordinates(row - 1, col - 1) && @board[row - 1][col - 1] == 1
      count += 1
    if @validCoordinates(row, col - 1) && @board[row][col - 1] == 1
      count += 1
    if @validCoordinates(row - 1, col + 1) && @board[row - 1][col + 1] == 1
      count += 1
    if @validCoordinates(row + 1, col - 1) && @board[row + 1][col - 1] == 1
      count += 1
    if @validCoordinates(row + 1, col) && @board[row + 1][col] == 1
      count += 1
    if @validCoordinates(row + 1, col + 1) && @board[row + 1][col + 1] == 1
      count += 1
    count

  # Given a row, col corresponding to the board coordinates, paint
  # cell live or dead, whatever the reverse is of its current state.
  # Note that the row, col coordinate pair mirrors the graphical
  # canvas, not the 2D board matrix. So we have to flip the board
  # indicies to account for this, since the matrix indices are the
  # opposite of the canvas axis's. As you go 'down' the matrix/iterate
  # through subarrays, X increases, whereas when you go 'down' the
  # canvas, Y increases.
  paintCell: (row, col) ->
    canvas = document.getElementById 'canvas'
    @ctx = canvas.getContext '2d'
    @cellsize = @canvasSize/@boardSize
    coords = [col * @cellsize, row * @cellsize, @cellsize, @cellsize]
    @ctx.strokeStyle = @lineColor
    @ctx.strokeRect.apply @ctx, coords
    if @board[col][row] == 1
      @board[col][row] = 0
    else
      @board[col][row] = 1
    @ctx.fillStyle = if @board[col][row] == 1 then @liveCellColor else @deadCellColor
    @ctx.fillRect.apply @ctx, coords

  paintBoard: ->
    @ctx = @canvasContext()
    @cellsize = @canvasSize/@boardSize
    for row in [0...@boardSize]
      for col in [0...@boardSize]
        coords = [row * @cellsize, col * @cellsize, @cellsize, @cellsize]
        @ctx.strokeStyle = @lineColor
        @ctx.strokeRect.apply @ctx, coords
        @ctx.fillStyle = if @board[row][col] == 1 then @liveCellColor else @deadCellColor
        @ctx.fillRect.apply @ctx, coords

  canvasContext: ->
    canvas = document.getElementById 'canvas'
    canvas.height = @canvasSize
    canvas.width = @canvasSize
    canvas.getContext '2d'

# callback
window.onload = () ->
  game = new GameOfLife()
  intervalID = -1
  $ ->
    $("#random").click =>
      game.randPopulateBoard()
      game.paintBoard()

    $("#clear").click ->
      clearInterval(intervalID);
      game.clearBoard()
      game.paintBoard()

    $("#start").click ->
      intervalID = setInterval =>
        game.runGeneration()
      , 50

    $("#pause").click ->
      clearInterval(intervalID);

    $("#step").click ->
      clearInterval(intervalID);
      game.runGeneration()

    $("#canvas").click (event) ->
      offsets = $('#canvas').offset()
      top = offsets.top;
      left = offsets.left;

      # brute force method of determining where on the board the
      # canvas click takes place
      for row in [0...game.boardSize]
        for col in [0...game.boardSize]
          if event.pageX >= left + col * game.cellsize &&
            event.pageX <= left + col * game.cellsize + game.cellsize &&
            event.pageY >= top + row * game.cellsize &&
            event.pageY <= top + row * game.cellsize + game.cellsize
              game.paintCell(row, col)
