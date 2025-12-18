extends Node

enum GameMode {
	PVP,
	PVE
}

var current_mode = GameMode.PVP
var cpu_difficulty = 1
var is_mobile = false

var bg_portrait = preload("res://assets/background.svg")
var bg_landscape = preload("res://assets/background_landscape.svg")

func _ready():
	_detect_device_and_setup()

func _detect_device_and_setup():
	var os_name = OS.get_name()
	# Check for mobile platforms
	if os_name == "Android" or os_name == "iOS":
		is_mobile = true
		# Mobile defaults to Portrait usually defined in project settings, 
		# but strictly speaking we trust the device orientation or lock it.
		# Project is set to Portrait by default now.
	else:
		is_mobile = false
		# For PC, we force a nice Landscape window
		DisplayServer.window_set_size(Vector2i(1280, 720))
		# Optional: Center the window
		var screen_size = DisplayServer.screen_get_size()
		var window_size = DisplayServer.window_get_size()
		DisplayServer.window_set_position(screen_size / 2 - window_size / 2)

func get_appropriate_background() -> Texture2D:
	if is_mobile:
		return bg_portrait
	else:
		# On PC we prefer landscape
		return bg_landscape
		
func apply_background_to_scene(bg_node: Sprite2D):
	bg_node.texture = get_appropriate_background()
	
	# Scale background to cover the whole viewport regardless of resolution
	var viewport_size = bg_node.get_viewport_rect().size
	var tex_size = bg_node.texture.get_size()
	
	var scale_x = viewport_size.x / tex_size.x
	var scale_y = viewport_size.y / tex_size.y
	
	# Use 'max' to simulate "Aspect Fill" (cover mode)
	var final_scale = max(scale_x, scale_y)
	bg_node.scale = Vector2(final_scale, final_scale) 

