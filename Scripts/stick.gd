extends Sprite2D

var can_pick = false
@onready var player = get_tree().get_first_node_in_group("player")
@onready var axe = get_tree().get_first_node_in_group("axe")

func pick():
	# DONT TOUCH THIS, IDK WHAT THIS DO
	var minDistance = 0.0
	var chosest_stick = 0.0
	for stick_node in get_node("/root/World/drops").get_children():
		var distance = player.position.distance_to(stick_node.position)
		if not chosest_stick:
			minDistance = distance
			chosest_stick = stick_node
			continue
		if distance < minDistance:
			minDistance = distance
			chosest_stick = stick_node
	# drop the axe
	if has_node("/root/World/player/axe"):
		axe.has_axe = false
		axe.global_position = chosest_stick.global_position
		axe.reparent(get_node("/root/World"), true)
	# pick the stick
	if chosest_stick and !player.has_stick:
		player.has_stick = true
		chosest_stick.global_position = Vector2(player.global_position.x+20, player.global_position.y)
		chosest_stick.reparent(player, true)

func _process(_delta):
	if Input.is_action_just_pressed("interact") and can_pick and !player.has_stick:
		pick()

func _on_collect_area_body_entered(_body):
	can_pick = true

func _on_collect_area_body_exited(_body):
	can_pick = false
