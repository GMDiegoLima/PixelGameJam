extends Control

func _on_play_pressed():
	BgMenuMusic.playing = false
	get_tree().change_scene_to_file("res://Levels/world.tscn")

func _on_options_pressed():
	get_tree().change_scene_to_file("res://Assets/UI/menu/options.tscn")


func _on_exit_pressed():
	get_tree().quit()
