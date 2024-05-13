extends CharacterBody2D

@export var speed: float = 300.0
var current_progress = 0
var has_stick = false
var can_build = false
var is_swimming = false
var bridge = preload("res://Scenes/bridge.tscn")
#@onready var animation_tree: AnimationTree = $AnimationTree
var direction: Vector2 = Vector2.ZERO

#func _ready():
	#animation_tree.active = true

func build():
	current_progress += 1
	$"../UI/ProgressBar".value = current_progress
	$"../UI/ProgressBar/HBoxContainer/current".text = str(current_progress)
	can_build = false
	if get_tree().get_nodes_in_group("stick"):
		for child in get_children():
			if child.is_in_group("stick"):
				child.can_pick = false
				child.call_deferred("free")
				has_stick = false
	match current_progress:
		1:
			$"../river/bridge/CollisionShape2D".disabled = true
			var bridge_instance = bridge.instantiate()
			$"../river/bridge".add_child(bridge_instance)
			bridge_instance.global_position = Vector2($"../river/bridge/bridge_spawn".global_position.x-25, $"../river/bridge/bridge_spawn".global_position.y)
		2:
			var bridge_instance = bridge.instantiate()
			$"../river/bridge".add_child(bridge_instance)
			bridge_instance.global_position = Vector2($"../river/bridge/bridge_spawn".global_position.x+75, $"../river/bridge/bridge_spawn".global_position.y)
		3:
			var bridge_instance = bridge.instantiate()
			$"../river/bridge".add_child(bridge_instance)
			bridge_instance.global_position = Vector2($"../river/bridge/bridge_spawn".global_position.x+175, $"../river/bridge/bridge_spawn".global_position.y)
		4:
			var bridge_instance = bridge.instantiate()
			$"../river/bridge".add_child(bridge_instance)
			bridge_instance.global_position = Vector2($"../river/bridge/bridge_spawn".global_position.x+275, $"../river/bridge/bridge_spawn".global_position.y)
		5:
			get_tree().change_scene_to_file("res://Scenes/world.tscn")

func _process(_delta):
	if Input.is_action_just_pressed("interact") and can_build and has_stick:
		build()
	#update_animation_parameters()

func _physics_process(_delta):
	direction = Input.get_vector("a", "d", "w", "s").normalized()
	if direction and !is_swimming:
		velocity = direction*speed
	elif !direction and is_swimming:
		velocity = Vector2(0, 1)*50
	elif direction and is_swimming:
		velocity = direction*150
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

func _on_bridge_body_entered(_body):
	$"../UI/corner_label".visible = true
	if has_stick:
		can_build = true
		$"../UI/corner_label".text = "press E to build"
	else:
		can_build = false
		$"../UI/corner_label".text = "You need stick to build"

func _on_bridge_body_exited(_body):
	can_build = false
	$"../UI/corner_label".visible = false

func _on_river_water_body_entered(_body):
	$water_mask.clip_children = 1
	is_swimming = true

func _on_river_water_body_exited(_body):
	$water_mask.clip_children = 0
	is_swimming = false
