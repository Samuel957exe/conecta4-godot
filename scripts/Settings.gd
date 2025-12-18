extends Control

@onready var volume_slider = $Panel/VBoxContainer/VolumeSlider
@onready var mute_check = $Panel/VBoxContainer/MuteCheck
@onready var btn_back = $Panel/VBoxContainer/BtnBack

func _ready():
	if has_node("Background"): # Note: Background node needs to be in Settings scene
		Global.apply_background_to_scene($Background)
		
	btn_back.pressed.connect(_on_back_pressed)
	volume_slider.value_changed.connect(_on_volume_changed)
	mute_check.toggled.connect(_on_mute_toggled)
	
	# Load current state
	mute_check.button_pressed = AudioManager.is_muted
	volume_slider.value = db_to_linear(AudioManager.current_volume_db)

func _on_volume_changed(value):
	AudioManager.set_volume(value)

func _on_mute_toggled(toggled):
	AudioManager.set_mute(toggled)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")
