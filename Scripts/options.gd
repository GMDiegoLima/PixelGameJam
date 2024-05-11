extends Control

@onready var master_slider = %master_slider
@onready var music_slider = %music_slider
@onready var sfx_slider = %sfx_slider

var user_prefs: UserPreferences

func _on_back_pressed():
	if get_tree().current_scene.name == "World":
		get_tree().paused = false
		queue_free()
	else:
		get_tree().change_scene_to_file("res://Assets/UI/menu/menu.tscn")

func _ready():
	user_prefs = UserPreferences.load_or_create()
	if master_slider:
		master_slider.value = user_prefs.master_volume
	if music_slider:
		music_slider.value = user_prefs.music_volume
	if sfx_slider:
		sfx_slider.value = user_prefs.sfx_volume

func _on_master_volume_value_changed(value):
	AudioServer.set_bus_volume_db(0, linear_to_db(value))
	AudioServer.set_bus_mute(0, value < 0.01)
	if user_prefs:
		user_prefs.master_volume = value
		user_prefs.save()

func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(1, linear_to_db(value))
	AudioServer.set_bus_mute(1, value < 0.01)
	if user_prefs:
		user_prefs.music_volume = value
		user_prefs.save()

func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(2, linear_to_db(value))
	AudioServer.set_bus_mute(2, value < 0.01)
	if user_prefs:
		user_prefs.sfx_volume = value
		user_prefs.save()
