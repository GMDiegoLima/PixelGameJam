extends CharacterBody2D

func _process(delta):
	velocity = Vector2(1, 0)*50
	move_and_slide()
