extends Node2D

var options_scene = preload("res://Assets/UI/menu/options.tscn")

func _process(_delta):
	if Input.is_action_just_pressed("esc"):
		if has_node("/root/World/options"):
			get_tree().paused = false
			get_node("/root/World/options").queue_free()
			print("HAS THE OPTIONS IN THE SCENE")
		else:
			get_tree().paused = true
			add_child(options_scene.instantiate())
			get_node("/root/World/options").position = %player.position
			get_node("/root/World/options").scale = Vector2(0.25, 0.25)
