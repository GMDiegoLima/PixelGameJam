extends Sprite2D

var can_chop: bool = false
var tree_life: int = 1
var stick = preload("res://Scenes/stick.tscn")

func drop_item(x_pos, y_post):
	var stick_instance = stick.instantiate()
	stick_instance.global_position = Vector2(x_pos+randi_range(1, 60), y_post+64+randi_range(1, 50))
	%drops.add_child(stick_instance)

func _process(_delta):
	if can_chop and Input.is_action_just_pressed("interact") and tree_life > 0:
		if has_node("/root/World/player/axe"):
			tree_life -= 1
	elif tree_life == 0:
		call_deferred("free")
		drop_item(global_position.x, global_position.y)
		drop_item(global_position.x, global_position.y)
		drop_item(global_position.x, global_position.y)
		drop_item(global_position.x, global_position.y)
		drop_item(global_position.x, global_position.y)

func _on_gather_area_body_entered(_body):
	$interact.visible = true
	if has_node("/root/World/player/axe"):
		$interact.text = "Press E to chop"
		can_chop = true
	else:
		$interact.text = "You need a axe to chop"
		can_chop = false

func _on_gather_area_body_exited(_body):
	$interact.visible = false
	can_chop = false
