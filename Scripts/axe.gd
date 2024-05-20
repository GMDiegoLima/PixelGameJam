extends Sprite2D

var has_axe = false
var can_get_axe = false
@onready var corner_label = $"../UI/Control/corner_label"

func link_axe():
	has_axe = true
	var player:Node2D = get_node("/root/World/player")
	# if has stick, drop the stick and get the axe
	if get_tree().get_nodes_in_group("stick"):
		for child in player.get_children():
			if child.is_in_group("stick"):
				player.has_stick = false
				child.visible = true
				child.global_position = global_position
				child.reparent(get_node("/root/World/drops"), true)
	# set the axe to the player
	visible = false
	$pick_area/CollisionShape2D.disabled = true
	reparent(player, true)

func _process(delta):
	if Input.is_action_just_pressed("interact") and !has_axe and can_get_axe:
		link_axe()

func _on_pick_area_body_entered(body):
	corner_label.visible = true
	corner_label.text = "Press E to pick the axe"
	can_get_axe = true

func _on_pick_area_body_exited(body):
	corner_label.visible = false
	can_get_axe = false
