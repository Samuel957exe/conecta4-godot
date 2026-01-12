extends Node2D

# Dimensiones del tablero
const ROWS: int = 6
const COLS: int = 7
const TILE_SIZE: int = 64

# Tablero de juego (matriz de listas)
# 0 = Vacío, 1 = Jugador 1, 2 = Jugador 2/CPU
var board = []

# Estado actual del juego
var current_player: int = 1 # 1: Rojo, 2: Amarillo
var game_over: bool = false
var is_animating: bool = false

# Referencias a nodos de la escena (se obtienen al inicio)
@onready var board_sprite: Sprite2D = $BoardSprite
@onready var tokens_container: Node2D = $Tokens
@onready var turn_label: Label = $UI/TurnLabel

# Texturas de las fichas para cargarlas rápidamente
var textures = {
	1: preload("res://assets/token_red.svg"),
	2: preload("res://assets/token_yellow.svg")
}

# Fuente pixelada para la interfaz
var pixel_font = preload("res://assets/fonts/PressStart2P-Regular.ttf")

func _ready() -> void:
	# Inicialización del juego al cargar la escena
	_init_board()       # Crear matriz vacía
	_center_grid()      # Centrar tablero en pantalla
	_update_ui()        # Poner texto inicial
	_create_back_button() # Crear botón de menú
	
	# Aplicar fondo responsivo si existe
	if has_node("Background"):
		Global.apply_background_to_scene($Background)

func _create_back_button() -> void:
	# Crea dinámicamente el botón para volver al menú
	var back_btn = Button.new()
	back_btn.text = "MENU"
	back_btn.position = Vector2(20, 20)
	
	# Asignar fuente si está disponible
	if pixel_font:
		back_btn.add_theme_font_override("font", pixel_font)
		back_btn.add_theme_font_size_override("font_size", 16)
		
	# Conectar señal de pulsado
	back_btn.pressed.connect(_on_back_pressed)
	$UI.add_child(back_btn)

func _init_board() -> void:
	# Prepara la matriz de datos con ceros (vacío)
	board.clear()
	for x in range(COLS):
		var col_arr = []
		col_arr.resize(ROWS)
		col_arr.fill(0)
		board.append(col_arr)

func _center_grid() -> void:
	# Calcula la posición para que el tablero quede centrado en cualquier resolución
	var screen_size = get_viewport_rect().size
	var board_size = Vector2(COLS * TILE_SIZE, ROWS * TILE_SIZE)
	var pos = (screen_size - board_size) / 2
	board_sprite.position = pos
	
	# Coloca el texto de turno encima del tablero
	if turn_label:
		turn_label.position = Vector2(pos.x, pos.y - 60)
		turn_label.custom_minimum_size.x = board_size.x
		turn_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		
		# Añadir contorno/sombra para asegurar legibilidad sobre nubes blancas
		turn_label.add_theme_color_override("font_outline_color", Color.BLACK)
		turn_label.add_theme_constant_override("outline_size", 8)
		turn_label.add_theme_color_override("font_shadow_color", Color(0,0,0,0.5))
		turn_label.add_theme_constant_override("shadow_offset_x", 3)
		turn_label.add_theme_constant_override("shadow_offset_y", 3)

func _input(event: InputEvent) -> void:
	# Si el juego terminó, cualquier clic reinicia
	if game_over:
		if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
			get_tree().reload_current_scene()
		return

	# Bloquear entrada si algo se mueve o es turno de CPU
	if is_animating or (Global.current_mode == Global.GameMode.PVE and current_player == 2):
		return

	# Detectar clic izquierdo en el tablero
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Calcular columna basada en la posición X del ratón relativa al tablero
		var local_x = event.position.x - board_sprite.position.x
		var col = int(local_x / TILE_SIZE)
		
		# Validar que el clic está dentro de los límites
		if col >= 0 and col < COLS and local_x >= 0 and event.position.y >= board_sprite.position.y:
			_play_turn(col)

func _play_turn(col: int) -> void:
	# Si la columna está llena, no hacer nada
	if board[col][0] != 0: return

	# Buscar primera fila vacía desde abajo hacia arriba
	var row = -1
	for y in range(ROWS - 1, -1, -1):
		if board[col][y] == 0:
			row = y
			break
	
	# Si hay hueco, animar caída
	if row != -1:
		_animate_drop(col, row)

func _animate_drop(col: int, row: int) -> void:
	is_animating = true
	# Crear sprite visual de la ficha
	var token = Sprite2D.new()
	token.texture = textures[current_player]
	tokens_container.add_child(token)
	
	# Calcular posiciones de inicio y fin
	var start_pos = board_sprite.position + Vector2(col * TILE_SIZE + TILE_SIZE / 2.0, -TILE_SIZE)
	var end_pos = board_sprite.position + Vector2(col * TILE_SIZE + TILE_SIZE / 2.0, row * TILE_SIZE + TILE_SIZE / 2.0)
	
	token.position = start_pos
	
	# Animar caída con efecto de rebote
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(token, "position", end_pos, 0.5)
	
	# Al terminar la animación, ejecutar lógica de aterrizaje
	tween.tween_callback(func(): _on_landed(col, row))

func _on_landed(col: int, row: int) -> void:
	AudioManager.play_hit_sound()    # Sonido de golpe
	board[col][row] = current_player # Registrar jugada en matriz lógica
	
	# Comprobaciones de final de partida
	if _check_win_aligned(col, row):
		_end_game(false) # Victoria
	elif _check_full():
		_end_game(true)  # Empate
	else:
		# Cambio de turno
		current_player = 3 - current_player
		_update_ui()
		is_animating = false
		
		# Si es modo vs CPU y toca CPU, programar movimiento
		if Global.current_mode == Global.GameMode.PVE and current_player == 2:
			await get_tree().create_timer(0.3).timeout # Pequeña pausa para naturalidad
			_cpu_move()

func _cpu_move() -> void:
	if game_over: return
	
	# IA Básica: Elige una columna válida al azar
	var valid_cols = []
	for i in range(COLS):
		if board[i][0] == 0: valid_cols.append(i)
	
	if valid_cols.size() > 0:
		_play_turn(valid_cols.pick_random())

func _check_win_aligned(c: int, r: int) -> bool:
	# Comprueba si hay 4 en raya desde la última posición colocada
	var p = board[c][r]
	var dirs = [[1,0], [0,1], [1,1], [1,-1]] # Horizontal, Vertical, Diag1, Diag2
	
	for d in dirs:
		var count = 1
		# Busca en ambas direcciones del eje
		for s in [1, -1]:
			for i in range(1, 4):
				var nc = c + d[0] * i * s
				var nr = r + d[1] * i * s
				# Si sigue siendo del mismo jugador, suma
				if nc >= 0 and nc < COLS and nr >= 0 and nr < ROWS and board[nc][nr] == p:
					count += 1
				else:
					break
		if count >= 4: return true
	return false

func _check_full() -> bool:
	# Comprueba si el tablero está lleno (empate)
	for c in range(COLS):
		if board[c][0] == 0: return false # Si la fila superior tiene un hueco, no está lleno
	return true

func _end_game(is_draw: bool) -> void:
	game_over = true
	var msg = ""
	
	if is_draw:
		msg = "¡EMPATE!"
		turn_label.modulate = Color(1, 1, 1) # Blanco para empate
	else:
		var winner_name = "ROJO" if current_player == 1 else "AMARILLO"
		if Global.current_mode == Global.GameMode.PVE:
			winner_name = "JUGADOR" if current_player == 1 else "CPU"
		msg = "¡" + winner_name + " GANA!"
		turn_label.modulate = Color(0, 1, 0) # Verde para victoria
	
	turn_label.text = msg
	is_animating = false

func _update_ui() -> void:
	# Actualiza el texto de a quién le toca
	var p_name = "ROJO" if current_player == 1 else "AMARILLO"
	if Global.current_mode == Global.GameMode.PVE:
		p_name = "JUGADOR" if current_player == 1 else "CPU"
	
	if turn_label:
		turn_label.text = "Turno: " + p_name
		turn_label.modulate = Color(1, 1, 1)

func _on_back_pressed() -> void:
	# Volver al menú principal
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")
