extends Node2D

var options_scene = preload("res://Assets/UI/menu/options.tscn")

var user_prefs: UserPreferences

func _ready():
	user_prefs = UserPreferences.load_or_create()
	if user_prefs:
		AudioServer.set_bus_volume_db(0, linear_to_db(user_prefs.master_volume))
		AudioServer.set_bus_volume_db(1, linear_to_db(user_prefs.music_volume))
		AudioServer.set_bus_volume_db(2, linear_to_db(user_prefs.sfx_volume))
	BgMenuMusic.playing = false
	BgGameIntro.playing = true

func _process(_delta):
	#if !BgGameIntro.playing and !$chase_music.playing:
		#BgGameLoop.playing = true
	if Input.is_action_just_pressed("esc"):
		if has_node("/root/World/options"):
			get_tree().paused = false
			get_node("/root/World/options").queue_free()
			print("HAS THE OPTIONS IN THE SCENE")
		else:
			get_tree().paused = true
			add_child(options_scene.instantiate())
			get_node("/root/World/options").position = %player.position
			get_node("/root/World/options").scale = Vector2(0.5, 0.5)
