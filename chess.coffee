$ -> 
  init()

init = ->
	messenger = new Messenger()
	model = new Model(messenger)
	view = new View(model)

class Messenger
	constructor: ->

	movePiece: (from, to) ->
		moveObj = {from: from, to: to}
		console.log JSON.stringify(moveObj)

class Pos
	constructor: (@row, @col) ->
	sameAs: (pos) ->
		pos.getRow() == @row && pos.getCol() == @col
	getRow: ->
		@row
	getCol: ->
		@col
	print: ->
		"col: " + @col + ", row: " + @row

class Piece
	constructor: (@type, @player, @pos, @model) ->
		if not (@player == "white" or @player == "black")
			console.log("invalid player")
		removed = false
		@hasMoved = false
	getPos: ->
		@pos
	setPos: (@pos) ->
	setHasMoved: (@hasMoved) ->
	getHasMoved: ->
		@hasMoved
	getPlayer: ->
		@player
	getType: ->
		@type
	getId: ->
		@id
	remove: ->
		@removed = true
		@finalPos = @pos
		@pos = new Pos(-1, -1)
	restore: ->
		if !@removed
			console.log "Attempting to restore a piece that was never removed!"
		@removed = false
		@pos = @finalPos
	getBasicMoves: ->
		[]
	getValidMoves: ->
		moves = @getBasicMoves()
		newMoves = []
		for m in moves	
			#strange bug is returning odd arrays so check that m is
			if m?
				if !@model.isCheckedAfterMove(@getPlayer(), this, m)
					newMoves.push m
		return newMoves
	validMove: (pos) ->
		for move in @getValidMoves()
			if move.sameAs(pos) 
				return true
		return false

class Pawn extends Piece
	constructor: (player, pos, model) ->
		super("pawn", player, pos, model)
	getBasicMoves: ->
		moves = []
		if @player == "white"
			dy = 1
		else if @player == "black"
			dy = -1

		newPos = new Pos(@pos.getRow() + dy, @pos.getCol())
		if @model.squareEmpty(newPos) && @model.onBoard(newPos)
			moves.push newPos

		if !@hasMoved
			newPos = new Pos(@pos.getRow() + 2*dy, @pos.getCol())
			if @model.squareEmpty(newPos) && @model.onBoard(newPos)
				moves.push newPos

		for dx in [-1,1]
			newPos = new Pos(@pos.getRow() + dy, @pos.getCol() + dx)
			pieceAtPos = @model.getPieceAt(newPos)
			if pieceAtPos? 
				if pieceAtPos.player != @getPlayer()
					moves.push newPos

		return moves


class Rook extends Piece
	constructor: (player, pos, model) ->
		super("rook", player, pos, model)

	getBasicMoves: ->
		moves = []

		for dxdy in [{dx: 0, dy: 1}, {dx: 0, dy: -1}, {dx: 1, dy: 0}, {dx: -1, dy: 0}]
			dx = dxdy.dx
			dy = dxdy.dy
			x = @pos.getCol()
			y = @pos.getRow()
			newPos = new Pos(y+dy,x+dx)
			while @model.onBoard(newPos) && @model.squareEmpty(newPos)
				moves.push newPos
				x = x + dx
				y = y + dy
				newPos = new Pos(y,x)
			if @model.onBoard(newPos) && !@model.squareEmpty(newPos) && @model.getPieceAt(newPos).player != @getPlayer()
				moves.push newPos
		
		#Castling moves are valid
		if @getPlayer() == "white"
			castlingRookPos = new Pos(0,7)
		else
			castlingRookPos = new Pos(7,0)
		if castlingRookPos.sameAs(@getPos()) #You're the castling rook
			if @hasMoved == false
				if @getPlayer() == "white"
					dx = -1
				else
					dx = 1
				pos = @getPos()
				if @model.squareEmpty(new Pos(pos.getRow(), pos.getCol()+dx)) && @model.squareEmpty(new Pos(pos.getRow(), pos.getCol()+2*dx))
					kingsPos = new Pos(pos.getRow(), pos.getCol()+3*dx)
					king = @model.getPieceAt(kingsPos)
					if king?
						if king.getHasMoved() == false && king.getType() == "king"
							moves.push kingsPos

		return moves


class Knight extends Piece
	constructor: (player, pos, model) ->
		super("knight", player, pos, model)

	getBasicMoves: ->
		moves = []

		for dxdy in [{dx: 2, dy: 1}, {dx: 2, dy: -1}, {dx: -2, dy: 1}, {dx: -2, dy: -1},
					{dy: 2, dx: 1}, {dy: 2, dx: -1}, {dy: -2, dx: 1}, {dy: -2, dx: -1}]
			dx = dxdy.dx
			dy = dxdy.dy
			x = @pos.getCol()
			y = @pos.getRow()
			newPos = new Pos(y+dy,x+dx)
			if @model.onBoard(newPos)
				if @model.squareEmpty(newPos)
					moves.push newPos
				else if @model.getPieceAt(newPos).player != @getPlayer()
			 		moves.push newPos

		return moves

class Bishop extends Piece
	constructor: (player, pos, model) ->
		super("bishop", player, pos, model)

	getBasicMoves: ->
		moves = []

		for dxdy in [{dx: 1, dy: 1}, {dx: -1, dy: -1}, {dx: 1, dy: -1}, {dx: -1, dy: 1}]
			dx = dxdy.dx
			dy = dxdy.dy
			x = @pos.getCol()
			y = @pos.getRow()
			newPos = new Pos(y+dy,x+dx)
			while @model.onBoard(newPos) && @model.squareEmpty(newPos)
				moves.push newPos
				x = x + dx
				y = y + dy
				newPos = new Pos(y,x)
			if @model.onBoard(newPos) && !@model.squareEmpty(newPos) && @model.getPieceAt(newPos).player != @getPlayer()
				moves.push newPos

		return moves

class Queen extends Piece
	constructor: (player, pos, model) ->
		super("queen", player, pos, model)

	getBasicMoves: ->
		moves = []

		for dxdy in [{dx: 1, dy: 1}, {dx: -1, dy: -1}, {dx: 1, dy: -1}, {dx: -1, dy: 1}, {dx: 0, dy: 1}, {dx: 0, dy: -1}, {dx: 1, dy: 0}, {dx: -1, dy: 0}]
			dx = dxdy.dx
			dy = dxdy.dy
			x = @pos.getCol()
			y = @pos.getRow()
			newPos = new Pos(y+dy,x+dx)
			while @model.onBoard(newPos) && @model.squareEmpty(newPos)
				moves.push newPos
				x = x + dx
				y = y + dy
				newPos = new Pos(y,x)
			if @model.onBoard(newPos) && !@model.squareEmpty(newPos) && @model.getPieceAt(newPos).player != @getPlayer()
				moves.push newPos

		return moves

class King extends Piece
	constructor: (player, pos, model) ->
		super("king", player, pos, model)

	getBasicMoves: ->
		moves = []

		for dxdy in [{dx: 1, dy: 1}, {dx: -1, dy: -1}, {dx: 1, dy: -1}, {dx: -1, dy: 1}, {dx: 0, dy: 1}, {dx: 0, dy: -1}, {dx: 1, dy: 0}, {dx: -1, dy: 0}]
			dx = dxdy.dx
			dy = dxdy.dy
			x = @pos.getCol()
			y = @pos.getRow()
			newPos = new Pos(y+dy,x+dx)
			if @model.onBoard(newPos) && (@model.squareEmpty(newPos) or (!@model.squareEmpty(newPos) && @model.getPieceAt(newPos).player != @getPlayer()))
				moves.push newPos

		#Castling moves are valid
		if @hasMoved == false
			if @getPlayer() == "white"
				dx = 1
			else
				dx = -1
			pos = @getPos()
			if @model.squareEmpty(new Pos(pos.getRow(), pos.getCol()+dx)) && @model.squareEmpty(new Pos(pos.getRow(), pos.getCol()+2*dx))
				piece = @model.getPieceAt(new Pos(pos.getRow(), pos.getCol()+3*dx))
				if piece?
					if piece.getHasMoved() == false && piece.getType() == "rook"
						moves.push new Pos(pos.getRow(), pos.getCol()+3*dx)

		return moves

class Model 
	constructor: (@messenger) ->
		@modelChangedListeners = []
		@resetBoard()

	resetBoard: ->
		@selected = null;
		@pieces = []
		@currentPlayer = "white"
		@pieces.push new Pawn("white", new Pos(1, i), this) for i in [0..7]
		@pieces.push new Pawn("black", new Pos(6, i), this) for i in [0..7]	
		@pieces.push new Rook("white", new Pos(0,0), this)		
		@pieces.push new Rook("white", new Pos(0,7), this)	
		@pieces.push new Rook("black", new Pos(7,0), this)		
		@pieces.push new Rook("black", new Pos(7,7), this)	
		@pieces.push new Knight("white", new Pos(0,1), this)		
		@pieces.push new Knight("white", new Pos(0,6), this)	
		@pieces.push new Knight("black", new Pos(7,1), this)		
		@pieces.push new Knight("black", new Pos(7,6), this)
		@pieces.push new Bishop("white", new Pos(0,2), this)		
		@pieces.push new Bishop("white", new Pos(0,5), this)	
		@pieces.push new Bishop("black", new Pos(7,2), this)		
		@pieces.push new Bishop("black", new Pos(7,5), this)	
		@pieces.push new Queen("white", new Pos(0,3), this)		
		@pieces.push new Queen("black", new Pos(7,4), this)	
		@pieces.push new King("white", new Pos(0,4), this)		
		@pieces.push new King("black", new Pos(7,3), this)	
		@modelChanged()

	getKing: (player) ->
		for piece in @pieces
			if piece.getPlayer() == player && piece.getType() == "king"
				return piece

	isChecked: (player) ->
		kingPos = @getKing(player).getPos()
		for piece in @pieces
			if piece.getPlayer() != player
				for move in piece.getBasicMoves()
					if kingPos.sameAs(move)
						return true
		return false
		
	isCheckedAfterMove: (player, piece, pos) ->
		check = false

		moveResult = @movePieceTemporarily(piece, pos)
		pieceUndoes = moveResult.pieceUndoes
		removedPiece = moveResult.removedPiece

		if @isChecked(player)
			check = true

		for pieceUndo in pieceUndoes
			@movePieceTemporarily(pieceUndo.piece, pieceUndo.oldPos)
		if removedPiece?
			removedPiece.restore()

		return check

	resetGame: ->
		resetBoard()
		@gameWon = null

	getGameWon: ->
		return @gameWon

	getCurrentPlayer: ->
		@currentPlayer

	getPieceAt: (pos) ->
		for piece in @pieces
			if piece.getPos().sameAs(pos)
				return piece
		return null

	squareEmpty: (pos) ->
		return !@getPieceAt(pos)?

	onBoard: (pos) ->
		pos.getRow() >= 0 && pos.getRow() < 8 && pos.getCol() >= 0 && pos.getCol() < 8

	clickSquare: (pos) ->
		if !gameWon?

			if @pieceSelected()

				#Handle moving
				if @getSelected().validMove(pos)
					@movePiece(@getSelected(), pos)
					@turnFinished()
					return
				else
					#Handle clicking an empty square to delect
					#if you clicked on the current piece return so we don't reselct it
					if pos.sameAs(@getSelected().getPos())
						@unsetSelected()
						return
					else
						@unsetSelected()

			#Handle selecting a piece
			piece = @getPieceAt(pos)
			if piece?
				if piece.player == @currentPlayer
					@setSelected(piece)
					return

	turnFinished: ->
		if @currentPlayer == "white"
			@currentPlayer = "black"
		else
			@currentPlayer = "white"
		if @isChecked("white")
			if @getKing("white").getValidMoves().length == 0
				@gameWon = "white"
		if @isChecked("black")
			if @getKing("black").getValidMoves().length == 0
				@gameWon = "black"
		@modelChanged()

	#if you move on top of another piece we temporarily remove it and return it. restore with piece.restore()
	movePieceTemporarily: (piece, pos) ->
		pieceUndoes = []
		castled = false
		#Handle king castling rook
		if piece.getType() == "king"
			if piece.getHasMoved() == false
				pieceClicked = @getPieceAt(pos)
				if pieceClicked?
					if pieceClicked.getType() == "rook" && piece.getPlayer() == pieceClicked.getPlayer() && pieceClicked.getHasMoved() == false
						if piece.getPlayer() == "white"
							rookEndPos = new Pos(0,5)
							kingEndPos = new Pos(0,6)
						else
							rookEndPos = new Pos(7,2)
							kingEndPos = new Pos(7,1)
						pieceUndoes.push {piece: pieceClicked, oldPos: pieceClicked.getPos()}
						pieceUndoes.push {piece: piece, oldPos: piece.getPos()}
						pieceClicked.setPos(rookEndPos)
						piece.setPos(kingEndPos)
						castled = true
		#Handle rook castling king
		if piece.getType() == "rook"
			if piece.getHasMoved() == false
				pieceClicked = @getPieceAt(pos)
				if pieceClicked?
					if pieceClicked.getType() == "king" && piece.getPlayer() == pieceClicked.getPlayer() && pieceClicked.getHasMoved() == false
						king = pieceClicked
						if piece.getPlayer() == "white"
							rookEndPos = new Pos(0,5)
							kingEndPos = new Pos(0,6)
						else
							rookEndPos = new Pos(7,2)
							kingEndPos = new Pos(7,1)
						pieceUndoes.push {piece: pieceClicked, oldPos: pieceClicked.getPos()}
						pieceUndoes.push {piece: piece, oldPos: piece.getPos()}
						king.setPos(kingEndPos)
						piece.setPos(rookEndPos)
						castled = true

		if !castled
			if @getPieceAt(pos)?
				removedPiece = @getPieceAt(pos)
				removedPiece.remove()
			oldPos = piece.getPos()
			piece.setPos(pos)
			pieceUndoes.push {piece: piece, oldPos: oldPos}
		
		return {pieceUndoes: pieceUndoes, removedPiece: removedPiece}


	movePiece: (piece, pos) ->
		@messenger.movePiece(piece.getPos(), pos)

		moveResult = @movePieceTemporarily(piece, pos)
		for pieceUndo in moveResult.pieceUndoes
			pieceUndo.piece.setHasMoved(true)

		@unsetSelected()
		@modelChanged()

	pieceSelected: ->
		@selected?

	unsetSelected: ->
		@selected = null
		@modelChanged()

	setSelected: (piece) ->
		@selected = piece
		@modelChanged()

	getSelected: ->
		if @pieceSelected()
			return @selected

	addModelChangedListener: (func) ->
		@modelChangedListeners.push(func)

	modelChanged: ->
		listener.modelChanged() for listener in @modelChangedListeners
		console.log "Model changed"

class View
	constructor: (@model) ->
		@drawer = new Drawer(@model)
		@redraw()
		@model.addModelChangedListener(@)

	modelChanged: ->
		@redraw()

	redraw: ->
		@drawer.draw()

	class Drawer
		constructor: (@model) ->
			for row in [0..7]
				for col in [0..7]
					pos = new Pos(row, col)
					top = @screenPosition(pos).top;
					left = @screenPosition(pos).left;
					id = row+"-"+col
					$("#board").append("<div id='"+id+"' " + "class='square'" +
						"style='position: absolute;
					 	top: "+top+"px; left: "+left+"px'>
					 	</div>")
					$("#"+id).bind("click", {model: @model, pos: new Pos(row, col)} , (e) -> e.data.model.clickSquare(e.data.pos))

		draw: ->
			$(".piece").remove()
			$(".highlight").remove()
			for row in [0..7]
				for col in [0..7]
					if !@model.squareEmpty(new Pos(row, col))
						$("#board").append(@getStringFor(@model.getPieceAt(new Pos(row, col))))
			if @model.pieceSelected()
				for pos in @model.getSelected().getValidMoves()
					top = @screenPosition(pos).top;
					left = @screenPosition(pos).left;
					$("#board").append("<div class='highlight' style='position: absolute;
			 		 	top: "+top+"px; left: "+left+"px'></div>")
			if @model.getGameWon()?
				console.log @model.getGameWon() + " wins!"
			else
				if @model.isChecked("white")
					console.log "White is in check"
				if @model.isChecked("black")
					console.log "Black is in check"


			# if @model.pieceSelected()
			# 	pos = @model.getSelected().getPos()
			# 	top = @screenPosition(pos).top;
			# 	left = @screenPosition(pos).left;
			# 	$("#board").append("<div class='highlight' style='position: absolute;
			# 		 top: "+top+"px; left: "+left+"px'></div>")


		getStringFor: (piece) ->
			top = @screenPosition(piece.getPos()).top;
			left = @screenPosition(piece.getPos()).left;
			"<div class='"+piece.getPlayer()+piece.getType()+" piece' 
				style=\"position: absolute;  background-image: url('images/"+piece.getPlayer()+piece.getType()+".png'); 
			 	top: "+top+"px; left: "+left+"px\">
			 	</div>"

		screenPosition: (pos) ->
			return {top: pos.getRow()*80, left: pos.getCol()*80}