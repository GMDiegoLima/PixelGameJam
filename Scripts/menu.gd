extends Control

var user_prefs: UserPreferences

func _ready():
	user_prefs = UserPreferences.load_or_create()
	if user_prefs:
		AudioServer.set_bus_volume_db(0, linear_to_db(user_prefs.master_volume))
		AudioServer.set_bus_volume_db(1, linear_to_db(user_prefs.music_volume))
		AudioServer.set_bus_volume_db(2, linear_to_db(user_prefs.sfx_volume))
	if !BgMenuMusic.playing:
		BgMenuMusic.playing = true

func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/world.tscn")

func _on_options_pressed():
	get_tree().change_scene_to_file("res://Assets/UI/menu/options.tscn")

func _on_exit_pressed():
	get_tree().quit()
