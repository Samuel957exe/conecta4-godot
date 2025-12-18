extends Node

var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var is_muted = false
var current_volume_db = 0.0

var hit_sound = null

func _ready():
	_setup_audio()
	play_music()
	
	if FileAccess.file_exists("res://assets/hit.wav"):
		hit_sound = load("res://assets/hit.wav")

func _setup_audio():
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	
	# Try to load music file
	if FileAccess.file_exists("res://assets/music.ogg"):
		var stream = load("res://assets/music.ogg")
		stream.loop = true
		music_player.stream = stream
	elif FileAccess.file_exists("res://assets/music.mp3"):
		var stream = load("res://assets/music.mp3")
		stream.loop = true
		music_player.stream = stream

func play_music():
	if music_player.stream and not music_player.playing:
		music_player.play()

func play_sfx(stream: AudioStream):
	if stream:
		sfx_player.stream = stream
		sfx_player.play()
		
func play_hit_sound():
	if hit_sound:
		play_sfx(hit_sound)

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
