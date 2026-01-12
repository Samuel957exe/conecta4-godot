extends Control

func _ready():
	# Aplicar fondo responsivo automáticamente si existe el nodo Background
	if has_node("Background"):
		Global.apply_background_to_scene($Background)

	# Conectar las señales de pulsado de botones a sus funciones
	$VBoxContainer/Btn1Player.pressed.connect(_on_1_player_pressed)
	$VBoxContainer/Btn2Players.pressed.connect(_on_2_players_pressed)
	$VBoxContainer/BtnSettings.pressed.connect(_on_settings_pressed)
	$VBoxContainer/BtnQuit.pressed.connect(_on_quit_pressed)

# Iniciar modo 1 jugador (vs CPU)
func _on_1_player_pressed():
	Global.current_mode = Global.GameMode.PVE
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

# Iniciar modo 2 jugadores (Local)
func _on_2_players_pressed():
	Global.current_mode = Global.GameMode.PVP
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

# Ir a ajustes
func _on_settings_pressed():
	get_tree().change_scene_to_file("res://scenes/Settings.tscn")

# Salir de la aplicación
func _on_quit_pressed():
	get_tree().quit()
