extends Piece
class_name Queen

var board: Board
var grid_pos := Vector2()
var is_white: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	board = get_parent()

	self.white_piece = load("res://Assets/White_Queen.png")
	self.black_piece = load("res://Assets/Black_Queen.png")
	
	update_color(get_node(("Sprite")))

var pos_to_check: Vector2
func generate_legal_moves() -> Array:
	var legal_moves := []
	
	for method_name in ["move_N", "move_S", "move_E", "move_W",
						"move_NE", "move_SE", "move_NW", "move_SW"]:
		call(method_name)
		set_pos_to_check()
		while board.is_in_grid(pos_to_check):
			legal_moves.append(pos_to_check)
			if board.get_tile(pos_to_check) != null:
				break
			call(method_name)
			set_pos_to_check()
		x = 0
		y = 0
	
	return legal_moves

func set_pos_to_check():
	pos_to_check = Vector2(x, y)

func move_N():
	y+=1
func move_S():
	y-=1
func move_E():
	x+=1
func move_W():
	x-=1
func move_SW():
	x-=1
	y+=1
func move_SE():
	x+=1
	y+=1
func move_NW():
	x-=1
	y-=1
func move_NE():
	x+=1
	y-=1
