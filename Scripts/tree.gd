extends Node2D

var can_chop: bool = false
var tree_life: int = 1
var stick = preload("res://Scenes/stick.tscn")

func drop_item(x_pos, y_post):
	var stick_instance = stick.instantiate()
	stick_instance.global_position = Vector2(x_pos+randi_range(1, 60), y_post+64+randi_range(1, 50))
	%drops.add_child(stick_instance)

func _process(_delta):
	if can_chop and Input.is_action_just_pressed("interact") and tree_life > 0:
		$AnimationPlayer.play("hit")
	elif tree_life == 0:
		call_deferred("free")
		drop_item(global_position.x, global_position.y)
		drop_item(global_position.x, global_position.y)
		drop_item(global_position.x, global_position.y)
		drop_item(global_position.x, global_position.y)
		drop_item(global_position.x, global_position.y)

func _on_gather_area_body_entered(_body):
	$"../UI/corner_label".visible = true
	if has_node("/root/World/player/axe"):
		$"../UI/corner_label".text = "Press E to chop"
		can_chop = true
	else:
		$"../UI/corner_label".text = "You need a axe to chop"
		can_chop = false

func _on_gather_area_body_exited(_body):
	$"../UI/corner_label".visible = false
	can_chop = false

func _on_animation_player_animation_finished(_anim_name):
	tree_life -= 1
