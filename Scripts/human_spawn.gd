extends Sprite2D

var human = preload("res://Scenes/human.tscn")

func spawn_human():
	var human_instance = human.instantiate()
	get_node("/root/World/human_paths").add_child(human_instance)
	human_instance.global_position = $human_spawn.global_position

func _on_frequency_to_spawn_timeout():
	spawn_human()
