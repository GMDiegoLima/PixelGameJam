extends Node2D

var can_chop: bool = false
var tree_life: int = 3
var stick = preload("res://Scenes/stick.tscn")

func drop_item(x_pos, y_post):
	var stick_instance = stick.instantiate()
	stick_instance.global_position = Vector2(x_pos+randi_range(1, 60), y_post+64+randi_range(1, 50))
	%drops.add_child(stick_instance)

func _process(delta):
	if can_chop and Input.is_action_just_pressed("interact") and tree_life > 0:
		$AnimationPlayer.play("hit")
		$chop_sfx.get_child(randi_range(0, 1)).play()

func _on_gather_area_body_entered(body):
	$"../UI/corner_label".visible = true
	if has_node("/root/World/player/axe"):
		$"../UI/corner_label".text = "Press E to chop"
		%player.tree_can_chop = true
		can_chop = true
	else:
		$"../UI/corner_label".text = "You need a axe to chop"
		%player.tree_can_chop = false
		can_chop = false

func _on_gather_area_body_exited(body):
	$"../UI/corner_label".visible = false
	can_chop = false

func _on_animation_player_animation_finished(anim_name):
	tree_life -= 1
	if tree_life == 0:
		$AnimationPlayer.play(["fall_left", "fall_right"].pick_random())
	if anim_name in ["fall_left", "fall_right"]:
		%player.tree_can_chop = false
		call_deferred("free")
		drop_item(global_position.x, global_position.y)
		drop_item(global_position.x, global_position.y)
		drop_item(global_position.x, global_position.y)
		drop_item(global_position.x, global_position.y)
		drop_item(global_position.x, global_position.y)
