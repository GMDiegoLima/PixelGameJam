extends Sprite2D

@onready var corner_label = get_tree().get_first_node_in_group("corner_label")
@onready var player = get_tree().get_first_node_in_group("player")

func _process(delta):
	if Input.is_action_just_pressed("interact") and player.can_build:
		$build_area/CollisionShape2D.disabled = true

func _on_build_area_body_entered(body):
	corner_label.visible = true
	if player.has_stick:
		player.can_build = true
		corner_label.text = "press E to build"
	else:
		player.can_build = false
		corner_label.text = "You need stick to build"

func _on_build_area_body_exited(body):
	player.can_build = false
	corner_label.visible = false
