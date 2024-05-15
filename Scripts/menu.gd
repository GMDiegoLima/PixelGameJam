extends Control

@onready var master_slider = %master_slider
@onready var music_slider = %music_slider
@onready var sfx_slider = %sfx_slider

var user_prefs: UserPreferences

func _ready():
	user_prefs = UserPreferences.load_or_create()
	if master_slider:
		master_slider.value = user_prefs.master_volume
	if music_slider:
		music_slider.value = user_prefs.music_volume
	if sfx_slider:
		sfx_slider.value = user_prefs.sfx_volume
	if !BgMenuMusic.playing:
		BgMenuMusic.playing = true

func _on_play_pressed():
	BgMenuMusic.playing = false
	get_tree().change_scene_to_file("res://Scenes/world.tscn")

func _on_options_pressed():
	get_tree().change_scene_to_file("res://Assets/UI/menu/options.tscn")

func _on_exit_pressed():
	get_tree().quit()
