extends Node2D

const ROWS = 6
const COLS = 7
const TILE_SIZE = 64
var BOARD_OFFSET = Vector2(100, 100)

var board = []
var current_player = 1 # 1: Red (Player), 2: Yellow (CPU/Player 2)
var game_over = false
var input_locked = false # To prevent input during CPU turn

@onready var board_sprite = $BoardSprite
@onready var tokens_container = $Tokens
@onready var turn_label = $UI/TurnLabel

var red_token_texture = preload("res://assets/token_red.svg")
var yellow_token_texture = preload("res://assets/token_yellow.svg")
var pixel_font = preload("res://assets/fonts/PressStart2P-Regular.ttf")

func _ready():
	_center_board()
	_init_board()
	_update_turn_label()
	
	# Apply responsive background
	# Assuming 'Background' node exists or we find it. 
	# Wait, in Main.tscn the background node is named "Background".
	if has_node("Background"):
		Global.apply_background_to_scene($Background)
	
	# Apply font to UI
	turn_label.add_theme_font_override("font", pixel_font)
	turn_label.add_theme_font_size_override("font_size", 24)
	
	var back_btn = Button.new()
	back_btn.text = "MENU"
	back_btn.position = Vector2(20, 20) # Top left
	back_btn.add_theme_font_override("font", pixel_font)
	back_btn.add_theme_font_size_override("font_size", 16)
	back_btn.pressed.connect(_on_back_pressed)
	$UI.add_child(back_btn)

func _center_board():
	var screen_size = get_viewport_rect().size
	var board_width = COLS * TILE_SIZE
	var board_height = ROWS * TILE_SIZE
	
	BOARD_OFFSET.x = (screen_size.x - board_width) / 2
	BOARD_OFFSET.y = (screen_size.y - board_height) / 2
	
	# Update BoardSprite position
	board_sprite.position = BOARD_OFFSET
	
	# Update Turn Label position to be above board
	turn_label.position.x = BOARD_OFFSET.x
	turn_label.position.y = BOARD_OFFSET.y - 60

func _init_board():
	board = []
	for x in range(COLS):
		board.append([])
		for y in range(ROWS):
			board[x].append(0)

func _input(event):
	if game_over:
		if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
			_reset_game()
		return
	
	if input_locked:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var col = _get_column_from_mouse(event.position)
		if col != -1:
			_attempt_move(col)

func _get_column_from_mouse(pos):
	var local_x = pos.x - BOARD_OFFSET.x
	if local_x < 0 or local_x >= COLS * TILE_SIZE:
		return -1
	return int(local_x / TILE_SIZE)

func _attempt_move(col):
	if input_locked:
		return
		
	if board[col][0] != 0:
		return # Column full
	
	_drop_token(col)

func _drop_token(col):
	var row = -1
	for y in range(ROWS - 1, -1, -1):
		if board[col][y] == 0:
			row = y
			break
	
	if row != -1:
		_animate_token_fall(col, row)

func _animate_token_fall(col, row):
	# Lock input during animation
	input_locked = true
	
	# Create token visual
	var token = Sprite2D.new()
	token.texture = red_token_texture if current_player == 1 else yellow_token_texture
	
	# Start position (above the board at the correct column)
	var start_pos = BOARD_OFFSET + Vector2(col * TILE_SIZE + TILE_SIZE/2, -TILE_SIZE)
	# Target position
	var end_pos = BOARD_OFFSET + Vector2(col * TILE_SIZE + TILE_SIZE/2, row * TILE_SIZE + TILE_SIZE/2)
	
	token.position = start_pos
	# Add behind the board (z-index wise), but we already handle this by scene tree order?
	# In Main.tscn: Background -> Tokens -> Board. So adding to Tokens node puts it behind Board.
	tokens_container.add_child(token)
	
	# Animate
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE) # Bounce effect for impact feel
	tween.set_ease(Tween.EASE_OUT)
	# Duration depends on how far it falls
	var distance_ratio = (row + 1) / float(ROWS)
	var duration = 0.4 + (0.1 * distance_ratio) 
	
	tween.tween_property(token, "position", end_pos, duration)
	tween.tween_callback(func(): _on_token_landed(col, row))

func _on_token_landed(col, row):
	# Play sound
	AudioManager.play_hit_sound()
	
	# Logic update
	board[col][row] = current_player
	
	if _check_win(col, row):
		_end_game(current_player)
	else:
		current_player = 3 - current_player
		_update_turn_label()
		
		# If PVE mode and it's now player 2's turn, trigger CPU
		if Global.current_mode == Global.GameMode.PVE and current_player == 2 and not game_over:
			# input_locked is ALREADY true, so we keep it true for CPU
			# Small delay for better feel
			await get_tree().create_timer(0.3).timeout
			_cpu_move()
		else:
			# Unlock input for player
			input_locked = false

# Removed old _place_token and integrated into _animate_token_fall -> _on_token_landed sequence

func _cpu_move():
	# Simple AI: 
	# 1. Check if can win
	# 2. Check if need to block
	# 3. Random valid move
	
	var move_col = -1
	
	# 1. Try to win (Naive check for now, just random for simplicity in this step, can be improved)
	# For now, let's just do random valid column to ensure it works, then improve if asked.
	var valid_cols = []
	for i in range(COLS):
		if board[i][0] == 0:
			valid_cols.append(i)
	
	if valid_cols.size() > 0:
		move_col = valid_cols.pick_random()
	
	if move_col != -1:
		_drop_token(move_col)
	
	input_locked = false

func _check_win(col, row):
	var player = board[col][row]
	var directions = [Vector2(1, 0), Vector2(0, 1), Vector2(1, 1), Vector2(1, -1)]
	
	for d in directions:
		var count = 1
		for i in range(1, 4):
			var c = col + d.x * i
			var r = row + d.y * i
			if _is_valid(c, r) and board[c][r] == player: count += 1
			else: break
		for i in range(1, 4):
			var c = col - d.x * i
			var r = row - d.y * i
			if _is_valid(c, r) and board[c][r] == player: count += 1
			else: break
		if count >= 4: return true
	return false

func _is_valid(c, r):
	return c >= 0 and c < COLS and r >= 0 and r < ROWS

func _end_game(winner):
	game_over = true
	var winner_name = "Red" if winner == 1 else "Yellow"
	if Global.current_mode == Global.GameMode.PVE and winner == 2:
		winner_name = "CPU"
	
	turn_label.text = winner_name + " Wins!"

func _update_turn_label():
	var p_name = "Red" if current_player == 1 else "Yellow"
	if Global.current_mode == Global.GameMode.PVE:
		if current_player == 1: p_name = "Player"
		else: p_name = "CPU"
		
	turn_label.text = "Turn: " + p_name

func _reset_game():
	get_tree().reload_current_scene()

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")
