extends Sprite2D

var has_axe = false
var can_get_axe = false


func link_axe():
	var player:Node2D = get_node("/root/World/player")
	# has stick, drop the stick and get the axe
	if get_tree().get_nodes_in_group("stick"):
		for child in player.get_children():
			if child.is_in_group("stick"):
				player.has_stick = false
				child.global_position = global_position
				child.reparent(get_node("/root/World/drops"), true)
	# set the axe to the player
	global_position = Vector2(player.global_position.x+20, player.global_position.y)
	reparent(player, true)

func _process(_delta):
	if Input.is_action_just_pressed("interact") and !has_axe and can_get_axe:
		has_axe = true
		link_axe()

func _on_area_2d_body_entered(_body):
	can_get_axe = true

func _on_area_2d_body_exited(_body):
	can_get_axe = false
