extends Node2D
class_name Board

var pieces_grid
var tiles_grid
const BOARD_SIZE = 8
const BOARD_LETTERS = "abcdefgh"

# Called when the node enters the scene tree for the first time.
func _ready():
	pieces_grid = initialize_empty_grid()
	intialize_pieces()
	tiles_grid = initialize_empty_grid()
	initialize_background_tiles()
	$Button.connect("button_up", self, "debug")

func debug():
	for algebraic_pos in "a1 b1 c1 d1 e1 a2".split(" "):
		print(get_piece_from_algebraic_pos(algebraic_pos))
		print(get_piece_from_algebraic_pos(algebraic_pos).grid_pos)
		for legal_move in get_piece_from_algebraic_pos(algebraic_pos).generate_legal_moves():
			print(grid_pos_to_algebraic_pos(legal_move))

func get_tile_from_grid_pos(pos: Vector2) -> Tile:
	return tiles_grid[pos[0]][pos[1]]

var selected_tile_pos: Vector2
var highlighted_movement_tiles: Array

# Deselecting previous actions
func undo_highlight() -> void:
	get_tile_from_grid_pos(selected_tile_pos).deselect()
	for tile in highlighted_movement_tiles:
		tile.dehighlight_movement()

func click_grid_pos(grid_pos: Vector2) -> void:
	undo_highlight()
	
	if !is_pos_empty(grid_pos):
		# Highlight the selected tile
		get_tile_from_grid_pos(grid_pos).select()
		selected_tile_pos = grid_pos
		
		# Highlight the possible movement tiles
		for legal_move in get_piece_from_grid_pos(grid_pos).generate_legal_moves():
			var tile: Tile = get_tile_from_grid_pos(legal_move)
			tile.highlight_movement()
			highlighted_movement_tiles.append(tile)

var TILE := load("res://Scenes/Tile.tscn")
var board_offset: Vector2
export(Color) var tile_color
export(Color) var tile_color_alternate

func initialize_background_tiles() -> void:
	var white = true
	for x in range(BOARD_SIZE):
		for y in range(BOARD_SIZE):
			var tile = TILE.instance()
			tile.init(Vector2(x, y) + board_offset)
			
			if !white:
				tile.set_color(tile_color)
			else:
				tile.set_color(tile_color_alternate)
				
			white = !white
			
			$Tiles.add_child(tile)
			tiles_grid[x][y] = tile
			tile.connect("button_up", self, "click_grid_pos", [tile.grid_pos])
		# Switches the tile color on a new row
		white = !white

func initialize_empty_grid() -> Array:
	var grid = []
	for x in range(BOARD_SIZE):
		grid.append([])
		for y in range(BOARD_SIZE):
			grid[x].append(null)
	return grid

var ROOK := load("res://Scenes/Rook.tscn")
var BISHOP := load("res://Scenes/Bishop.tscn")
var KNIGHT := load("res://Scenes/Knight.tscn")
var QUEEN := load("res://Scenes/Queen.tscn")
var KING := load("res://Scenes/King.tscn")
var PAWN := load("res://Scenes/Pawn.tscn")

func intialize_pieces() -> void:
	var algebraic_pos: String
	
	# Adding pawns
	for letter in BOARD_LETTERS:
		algebraic_pos = letter + str(2)
		add_child(PAWN.instance().init(algebraic_pos, true))
		algebraic_pos = letter + str(7)
		add_child(PAWN.instance().init(algebraic_pos, false))
	
	# Adding major pieces
	var pieces := "Ra1 Nb1 Bc1 Qd1 Ke1 Bf1 Ng1 Rh1"
	var letter_to_piece := {"R": ROOK, "B": BISHOP, "N": KNIGHT, "Q": QUEEN, "K": KING}
	for piece in pieces.split(" "):
		var node = letter_to_piece[piece[0]]
		add_child(node.instance().init(piece.right(1), true))
		add_child(node.instance().init(piece[1] + str(BOARD_SIZE), false))

func get_piece_from_grid_pos(pos: Vector2) -> Piece:
	return pieces_grid[pos[0]][pos[1]]

func get_piece_from_algebraic_pos(pos: String) -> Piece:
	var grid_pos := algebraic_pos_to_grid_pos(pos)
	return get_piece_from_grid_pos(grid_pos)

func is_pos_empty(pos: Vector2) -> bool:
	return get_piece_from_grid_pos(pos) == null

func does_pos_have_enemy(pos: Vector2, piece: Piece) -> bool:
	if !is_pos_empty(pos):
		return get_piece_from_grid_pos(pos).is_white != piece.is_white
	return false

func does_pos_have_ally(pos: Vector2, piece: Piece) -> bool:
	if !is_pos_empty(pos):
		return get_piece_from_grid_pos(pos).is_white == piece.is_white
	return false

func is_in_grid(pos: Vector2) -> bool:
	for num in [pos.x, pos.y]:
		if num<0 or num>=BOARD_SIZE:
			return false
	return true

func algebraic_pos_to_grid_pos(pos: String) -> Vector2:
	assert(len(pos)==2)
	assert(pos[1].is_valid_integer())
	
	var new_pos: Vector2
	new_pos.x = ord(pos.to_lower()[0])-ord('a')
	new_pos.y = BOARD_SIZE - int(pos[1])
	return new_pos

func grid_pos_to_algebraic_pos(pos: Vector2) -> String:
	return char(pos.x+ord('a')) + str(BOARD_SIZE - int(pos.y))
