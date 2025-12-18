extends Node

var music_player: AudioStreamPlayer
var is_muted = false
var current_volume_db = 0.0

func _ready():
	_setup_audio()
	play_music()

func _setup_audio():
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	
	# Try to load music file
	if FileAccess.file_exists("res://assets/music.ogg"):
		var stream = load("res://assets/music.ogg")
		stream.loop = true
		music_player.stream = stream
	elif FileAccess.file_exists("res://assets/music.mp3"):
		var stream = load("res://assets/music.mp3")
		stream.loop = true
		music_player.stream = stream
	else:
		print("AudioManager: No music file found at res://assets/music.ogg or .mp3")

func play_music():
	if music_player.stream and not music_player.playing:
		music_player.play()

func set_volume(value: float):
	# Value between 0 and 1
	var db = linear_to_db(value)
	current_volume_db = db
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)
	
func set_mute(enabled: bool):
	is_muted = enabled
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), enabled)

func toggle_mute():
	set_mute(!is_muted)
