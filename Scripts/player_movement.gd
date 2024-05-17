extends CharacterBody2D

@export var speed:float = 300.0
var current_progress:int = 0

var has_stick:bool = false
@export var inside_tree_range:bool = false
@export var chop_animation_finished:bool = false

var can_build:bool = false
var is_swimming:bool = false
var bridge = preload("res://Scenes/bridge.tscn")

@onready var animation_tree:AnimationTree = $AnimationTree
var direction:Vector2 = Vector2.ZERO

func _ready():
	animation_tree.active = true

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
			bridge_instance.global_position = Vector2($"../river/bridge/bridge_spawn".global_position.x-55, $"../river/bridge/bridge_spawn".global_position.y)
		2:
			var bridge_instance = bridge.instantiate()
			$"../river/bridge".add_child(bridge_instance)
			bridge_instance.global_position = Vector2($"../river/bridge/bridge_spawn".global_position.x, $"../river/bridge/bridge_spawn".global_position.y)
		3:
			var bridge_instance = bridge.instantiate()
			$"../river/bridge".add_child(bridge_instance)
			bridge_instance.global_position = Vector2($"../river/bridge/bridge_spawn".global_position.x+55, $"../river/bridge/bridge_spawn".global_position.y)
		4:
			var bridge_instance = bridge.instantiate()
			$"../river/bridge".add_child(bridge_instance)
			bridge_instance.global_position = Vector2($"../river/bridge/bridge_spawn".global_position.x+110, $"../river/bridge/bridge_spawn".global_position.y)
		5:
			get_tree().change_scene_to_file("res://Scenes/world.tscn")

func _process(_delta):
	if Input.is_action_just_pressed("interact") and can_build and has_stick:
		build()
	update_animation_parameters()

func _physics_process(_delta):
	direction = Input.get_vector("a", "d", "w", "s").normalized()
	if direction and !is_swimming and !$AnimationTree["parameters/conditions/chop"]:
		velocity = direction*speed
	elif !direction and is_swimming:
		velocity = Vector2(0, 1)*50
	elif direction and is_swimming:
		velocity = direction*150
	else:
		velocity = Vector2.ZERO
	move_and_slide()

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
	$water_mask.self_modulate = Color(1, 1, 1, 1)
	is_swimming = true

func _on_river_water_body_exited(_body):
	$water_mask.clip_children = 0
	$water_mask.self_modulate = Color(0, 0, 0, 0)
	is_swimming = false
	
func update_animation_parameters():
	if velocity == Vector2.ZERO:
		if has_stick:
			$AnimationTree["parameters/conditions/idle"] = false
			$AnimationTree["parameters/conditions/stick_idle"] = true
			$AnimationTree["parameters/conditions/stick_walk"] = false
			$AnimationTree["parameters/conditions/axe_idle"] = false
		elif has_node("/root/World/player/axe"):
			if Input.is_action_just_pressed("interact") and inside_tree_range:
				$AnimationTree["parameters/conditions/chop"] = true
				$AnimationTree["parameters/conditions/axe_idle"] = false
				$AnimationTree["parameters/conditions/axe_walk"] = false
			else:
				$AnimationTree["parameters/conditions/idle"] = false
				$AnimationTree["parameters/conditions/stick_idle"] = false
				$AnimationTree["parameters/conditions/axe_idle"] = true
				$AnimationTree["parameters/conditions/axe_walk"] = false
		else:
			$AnimationTree["parameters/conditions/idle"] = true
			$AnimationTree["parameters/conditions/walk"] = false
			$AnimationTree["parameters/conditions/stick_idle"] = false
			$AnimationTree["parameters/conditions/axe_idle"] = false
	else:
		if has_stick:
			$AnimationTree["parameters/conditions/walk"] = false
			$AnimationTree["parameters/conditions/stick_idle"] = false
			$AnimationTree["parameters/conditions/stick_walk"] = true
			$AnimationTree["parameters/conditions/axe_walk"] = false
		elif has_node("/root/World/player/axe"):
			$AnimationTree["parameters/conditions/walk"] = false
			$AnimationTree["parameters/conditions/stick_walk"] = false
			$AnimationTree["parameters/conditions/axe_idle"] = false
			$AnimationTree["parameters/conditions/axe_walk"] = true
		else:
			$AnimationTree["parameters/conditions/idle"] = false
			$AnimationTree["parameters/conditions/walk"] = true
			$AnimationTree["parameters/conditions/stick_walk"] = false
			$AnimationTree["parameters/conditions/axe_walk"] = false
	if direction != Vector2.ZERO and !$AnimationTree["parameters/conditions/chop"]:
		$AnimationTree["parameters/idle/blend_position"] = direction
		$AnimationTree["parameters/walk/blend_position"] = direction
		$AnimationTree["parameters/axe_idle/blend_position"] = direction
		$AnimationTree["parameters/axe_walk/blend_position"] = direction
		#$AnimationTree["parameters/stick_idle/blend_position"] = direction
		#$AnimationTree["parameters/stick_walk/blend_position"] = direction
		$AnimationTree["parameters/chop/blend_position"] = direction
		$AnimationTree["parameters/swim/blend_position"] = direction
		if direction == Vector2(1, 0):
			$water_mask/AnimatedSprite2D.flip_h = false
		elif  direction == Vector2(-1, 0):
			$water_mask/AnimatedSprite2D.flip_h = true
		else:
			$water_mask/AnimatedSprite2D.flip_h = false

func _on_animation_tree_animation_finished(anim_name):
	if anim_name in ["chop_down", "chop_up" , "chop_side"]:
		chop_animation_finished = true
		$AnimationTree["parameters/conditions/chop"] = false
		$AnimationTree["parameters/conditions/axe_idle"] = true
