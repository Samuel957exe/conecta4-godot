extends Control

func _ready():
	# Apply responsive background
	if has_node("Background"):
		Global.apply_background_to_scene($Background)

	# Connect button signals
	$VBoxContainer/Btn1Player.pressed.connect(_on_1_player_pressed)
	$VBoxContainer/Btn2Players.pressed.connect(_on_2_players_pressed)
	$VBoxContainer/BtnSettings.pressed.connect(_on_settings_pressed)
	$VBoxContainer/BtnQuit.pressed.connect(_on_quit_pressed)

func _on_1_player_pressed():
	Global.current_mode = Global.GameMode.PVE
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_2_players_pressed():
	Global.current_mode = Global.GameMode.PVP
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://scenes/Settings.tscn")

func _on_quit_pressed():
	get_tree().quit()
