extends Node

# Enumeración para definir los tipos de juego disponibles
enum GameMode {
	PVP, # Jugador contra Jugador
	PVE  # Jugador contra Entorno (CPU)
}

# Variables globales accesibles desde cualquier sitio
var current_mode = GameMode.PVP # Modo seleccionado por defecto
var cpu_difficulty = 1          # Dificultad (para futuro uso)
var is_mobile = false           # Flag para saber si estamos en móvil

# Recursos de fondo precargados
var bg_portrait = preload("res://assets/background.svg")
var bg_landscape = preload("res://assets/background_landscape.svg")

func _ready():
	_detect_device_and_setup()

# Configura la ventana dependiendo de si es PC o Móvil
func _detect_device_and_setup():
	var os_name = OS.get_name()
	# Detectar sistemas operativos móviles
	if os_name == "Android" or os_name == "iOS":
		is_mobile = true
	else:
		is_mobile = false
		# En PC, forzamos una resolución panorámica cómoda
		DisplayServer.window_set_size(Vector2i(1280, 720))
		# Centrar ventana en pantalla de ordenador
		var screen_size = DisplayServer.screen_get_size()
		var window_size = DisplayServer.window_get_size()
		DisplayServer.window_set_position(screen_size / 2 - window_size / 2)

# Devuelve el fondo adecuado según orientación
func get_appropriate_background() -> Texture2D:
	if is_mobile:
		return bg_portrait
	else:
		return bg_landscape
		
# Aplica y escala el fondo para cubrir toda la pantalla (tipo "object-fit: cover")
func apply_background_to_scene(bg_node: Sprite2D):
	bg_node.texture = get_appropriate_background()
	
	var viewport_size = bg_node.get_viewport_rect().size
	var tex_size = bg_node.texture.get_size()
	
	var scale_x = viewport_size.x / tex_size.x
	var scale_y = viewport_size.y / tex_size.y
	
	# Usar el mayor factor de escala asegura que no queden bordes negros
	var final_scale = max(scale_x, scale_y)
	bg_node.scale = Vector2(final_scale, final_scale) 

