extends CharacterBody2D

@export var speed: float = 300.0
var has_stick = false
#@onready var animation_tree: AnimationTree = $AnimationTree
var direction: Vector2 = Vector2.ZERO

#func _ready():
	#animation_tree.active = true

#func _process(_delta):
	#update_animation_parameters()

func _physics_process(_delta):
	direction = Input.get_vector("a", "d", "w", "s").normalized()
	if direction:
		velocity = direction*speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()

#func update_animation_parameters():
	#if velocity == Vector2.ZERO and !is_sitting:
		#animation_tree["parameters/conditions/idle"] = true
		#animation_tree["parameters/conditions/moving"] = false
	#elif velocity != Vector2.ZERO and !is_sitting:
		#animation_tree["parameters/conditions/idle"] = false
		#animation_tree["parameters/conditions/moving"] = true
	#if can_chop and Input.is_action_just_pressed("act"):
		#position = left_chair.global_position
		#left_chair.get_node("Label").visible = false
		#animation_tree["parameters/conditions/idle"] = false
		#animation_tree["parameters/conditions/moving"] = false
		#animation_tree["parameters/conditions/chopping"] = is_sitting
	#if direction != Vector2.ZERO:
		#animation_tree["parameters/idle/blend_position"] = direction
		#animation_tree["parameters/chop/blend_position"] = direction
		#animation_tree["parameters/walk/blend_position"] = direction
