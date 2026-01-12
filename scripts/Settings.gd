extends Control

# Referencias a los componentes de la interfaz de usuario (UI)
@onready var volume_slider = $Panel/VBoxContainer/VolumeSlider # Deslizador de volumen
@onready var mute_check = $Panel/VBoxContainer/MuteCheck       # Casilla de silenciar
@onready var btn_back = $Panel/VBoxContainer/BtnBack            # Botón de volver
@onready var fullscreen_check = $Panel/VBoxContainer/FullscreenCheck # Casilla de pantalla completa

func _ready():
	# Aplicar fondo responsivo si existe en la escena
	if has_node("Background"): 
		Global.apply_background_to_scene($Background)
		
	# Conectar señales de los controles a sus funciones
	btn_back.pressed.connect(_on_back_pressed)
	volume_slider.value_changed.connect(_on_volume_changed)
	mute_check.toggled.connect(_on_mute_toggled)
	
	# Cargar estado actual del audio desde el AudioManager
	mute_check.button_pressed = AudioManager.is_muted
	# Convertir de dB (logarítmico) a lineal (0-1) para el slider
	volume_slider.value = db_to_linear(AudioManager.current_volume_db)

	# Configuración específica para PC (Pantalla completa)
	if OS.has_feature("pc"):
		fullscreen_check.toggled.connect(_on_fullscreen_toggled)
		# Verificar si ya estamos en pantalla completa para marcar la casilla
		fullscreen_check.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	else:
		# En móviles suele ser pantalla completa por defecto, ocultamos la opción
		fullscreen_check.visible = false

# Se ejecuta al mover el deslizador de volumen
func _on_volume_changed(value):
	AudioManager.set_volume(value)

# Se ejecuta al marcar/desmarcar la casilla de silencio
func _on_mute_toggled(toggled):
	AudioManager.set_mute(toggled)

# Se ejecuta al cambiar la opción de pantalla completa (Solo PC)
func _on_fullscreen_toggled(toggled):
	if toggled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

# Volver al menú principal
func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")
