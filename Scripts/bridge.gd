extends Sprite2D

@onready var corner_label = get_tree().get_first_node_in_group("corner_label")
@onready var player = get_tree().get_first_node_in_group("player")

func _process(delta):
	if player.has_stick and corner_label.visible:
		player.can_build = true
		corner_label.text = "press E to build"
	else:
		player.can_build = false
		corner_label.text = "You need stick to build"
	if Input.is_action_just_pressed("interact") and player.can_build:
		match player.current_progress:
			2,5,8,11,14,17,20,23,26,29:
				$build_area/CollisionShape2D.disabled = true
				$build_area/CollisionShape2D2.disabled = true
				$building_icons.visible = false

func _on_build_area_body_entered(body):
	corner_label.visible = true

func _on_build_area_body_exited(body):
	player.can_build = false
	corner_label.visible = false
