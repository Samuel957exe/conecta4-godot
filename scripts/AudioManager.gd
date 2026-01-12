extends Node

# Reproductores de audio para música y efectos
var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

var is_muted = false
var current_volume_db = 0.0

# Almacenar sonidos para acceso rápido
var hit_sound = null

func _ready():
	_setup_audio()
	play_music()
	
	# Cargar sonido de golpe si existe
	if FileAccess.file_exists("res://assets/hit.wav"):
		hit_sound = load("res://assets/hit.wav")

func _setup_audio():
	# Crear nodos de audio dinámicamente y añadirlos a la escena global
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	
	# Intentar cargar música de fondo (ogg o mp3)
	if FileAccess.file_exists("res://assets/music.ogg"):
		var stream = load("res://assets/music.ogg")
		stream.loop = true
		music_player.stream = stream
	elif FileAccess.file_exists("res://assets/music.mp3"):
		var stream = load("res://assets/music.mp3")
		stream.loop = true
		music_player.stream = stream

# Reproducir música en bucle
func play_music():
	if music_player.stream and not music_player.playing:
		music_player.play()

# Reproducir un efecto de sonido
func play_sfx(stream: AudioStream):
	if stream:
		sfx_player.stream = stream
		sfx_player.play()

# Helper específico para el sonido de ficha
func play_hit_sound():
	if hit_sound:
		play_sfx(hit_sound)

# Ajustar volumen general (0.0 a 1.0)
func set_volume(value: float):
	var db = linear_to_db(value) # Convertir lineal a decibelios
	current_volume_db = db
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)

# Silenciar/Desilenciar todo
func set_mute(enabled: bool):
	is_muted = enabled
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), enabled)

func toggle_mute():
	set_mute(!is_muted)
