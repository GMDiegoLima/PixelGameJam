extends Sprite2D

@onready var can_talk: bool = false
const lines: Array[String] = ["BOMMY SAID: HAS SOME PLACES WHERE YOU ARE SAFE FROM HUMANS"]

func _process(delta):
	if can_talk and Input.is_action_just_pressed("interact"):
		DialogManager.start_dialog(global_position, lines)

func _on_talk_area_body_entered(body):
	$"../UI/Control/corner_label".visible = true
	$"../UI/Control/corner_label".text = "Press E To Talk"
	can_talk = true

func _on_talk_area_body_exited(body):
	$"../UI/Control/corner_label".visible = false
	can_talk = false
