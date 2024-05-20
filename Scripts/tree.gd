extends Node2D

var chop_area:bool = false
var tree_life:int = 3
var stick = preload("res://Scenes/stick.tscn")

func drop_item(x_pos, y_post):
	var stick_instance = stick.instantiate()
	stick_instance.global_position = Vector2(x_pos+randi_range(1, 60), y_post+64+randi_range(1, 50))
	%drops.add_child(stick_instance)

func _process(delta):
	if %player.chop_animation_finished and chop_area and tree_life > 0:
		$chop_sfx.get_child(randi_range(0, 1)).play()
		$AnimationPlayer.play("hit")
		%player.chop_animation_finished = false
	if tree_life > 0 and has_node("/root/World/player/axe")  and chop_area:
		$"../../UI/Control/corner_label".text = "Press E to chop"
		%player.inside_tree_range = true
	elif tree_life > 0 and !has_node("/root/World/player/axe") and chop_area:
		$"../../UI/Control/corner_label".text = "You need a axe to chop"
		%player.inside_tree_range = false

func _on_gather_area_body_entered(body):
	if body.name == "player":
		$"../../UI/Control/corner_label".visible = true
		chop_area = true

func _on_gather_area_body_exited(body):
	if body.name == "player":
		body.inside_tree_range = false
		$"../../UI/Control/corner_label".visible = false
		chop_area = false

func _on_animation_player_animation_finished(anim_name):
	tree_life -= 1
	if tree_life == 0:
		$AnimationPlayer.play(["fall_left", "fall_right"].pick_random())
	if anim_name in ["fall_left", "fall_right"]:
		call_deferred("free")
		if tree_life < 1:
			for i in randf_range(4, 7):
				drop_item(global_position.x, global_position.y)
