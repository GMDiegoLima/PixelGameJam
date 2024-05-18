extends CharacterBody2D

var speed:float = 175.0
var current_progress:int = 0

var has_stick:bool = false
@export var inside_tree_range:bool = false
var chop_animation_finished:bool = false

var can_build:bool = false
var bridge = preload("res://Scenes/bridge.tscn")

var is_swimming:bool = false
var is_being_chased:bool = false
var grabbed = false
@onready var chase_music = $"../chase_music"

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
	$sfx/building_sfx.play()
	match current_progress:
		1:
			$"../river/bridge/CollisionShape2D".disabled = true
			var bridge_instance = bridge.instantiate()
			$"../river/bridge".add_child(bridge_instance)
			bridge_instance.global_position = Vector2($"../river/bridge/bridge_spawn".global_position.x, $"../river/bridge/bridge_spawn".global_position.y)
		5:
			var bridge_instance = bridge.instantiate()
			$"../river/bridge".add_child(bridge_instance)
			bridge_instance.global_position = Vector2($"../river/bridge/bridge_spawn".global_position.x+55, $"../river/bridge/bridge_spawn".global_position.y)
		10:
			var bridge_instance = bridge.instantiate()
			$"../river/bridge".add_child(bridge_instance)
			bridge_instance.global_position = Vector2($"../river/bridge/bridge_spawn".global_position.x+110, $"../river/bridge/bridge_spawn".global_position.y)
		15:
			var bridge_instance = bridge.instantiate()
			$"../river/bridge".add_child(bridge_instance)
			bridge_instance.global_position = Vector2($"../river/bridge/bridge_spawn".global_position.x+165, $"../river/bridge/bridge_spawn".global_position.y)
		20:
			var bridge_instance = bridge.instantiate()
			$"../river/bridge".add_child(bridge_instance)
			bridge_instance.global_position = Vector2($"../river/bridge/bridge_spawn".global_position.x+220, $"../river/bridge/bridge_spawn".global_position.y)
		25:
			var bridge_instance = bridge.instantiate()
			$"../river/bridge".add_child(bridge_instance)
			bridge_instance.global_position = Vector2($"../river/bridge/bridge_spawn".global_position.x+285, $"../river/bridge/bridge_spawn".global_position.y)
		30:
			get_tree().change_scene_to_file("res://Scenes/world.tscn")

func _process(_delta):
	if Input.is_action_just_pressed("interact") and can_build and has_stick:
		build()
	if !$sfx/steps_sfx.playing and direction and !is_swimming:
		$sfx/steps_sfx.play()
	if is_swimming and !$sfx/swim_sfx.playing:
		$sfx/swim_sfx.play()
	elif !is_swimming and $sfx/swim_sfx.playing:
		$sfx/swim_sfx.stop()

func _physics_process(_delta):
	update_animation_parameters()
	if is_being_chased and !chase_music.playing:
		BgGameIntro.stop()
		BgGameLoop.stop()
		chase_music.play()
	elif !is_being_chased and chase_music.playing:
		chase_music.stop()
		BgGameLoop.play()
	direction = Input.get_vector("a", "d", "w", "s").normalized()
	if direction and !is_swimming and !grabbed and !$AnimationTree["parameters/conditions/chop"]:
		velocity = direction*speed
	elif !direction and is_swimming:
		velocity = Vector2(0, 1)*100
	elif direction and is_swimming:
		velocity = direction*80-Vector2(0, -1)*10
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
		$AnimationTree["parameters/stick_idle/blend_position"] = direction
		$AnimationTree["parameters/stick_walk/blend_position"] = direction
		$AnimationTree["parameters/chop/blend_position"] = direction
		$AnimationTree["parameters/swim/blend_position"] = direction
		if direction == Vector2(1, 0):
			$water_mask/AnimatedSprite2D.flip_h = false
		elif  direction.x < 0 and direction.x <= direction.y:
			$water_mask/AnimatedSprite2D.flip_h = true
		else:
			$water_mask/AnimatedSprite2D.flip_h = false

func _on_animation_tree_animation_finished(anim_name):
	if anim_name in ["chop_down", "chop_up" , "chop_side"]:
		chop_animation_finished = true
		$AnimationTree["parameters/conditions/chop"] = false
		$AnimationTree["parameters/conditions/axe_idle"] = true
