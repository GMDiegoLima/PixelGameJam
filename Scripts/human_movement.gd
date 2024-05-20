extends CharacterBody2D

@onready var target_position = null
var last_pos:Vector2 = Vector2.ZERO
@onready var previous_position:Vector2 = global_position
var direction = Vector2.ZERO

var chopping_tree = null
var has_wood:bool = false

var timer_inactive:bool = true
var path_index:int = 0
var in_path_line:bool = true
@onready var human_node = get_parent()
@onready var path_spawn = human_node.get_node("human_spawned/follow")
@onready var chosen_path = [$"../human_path1/follow", $"../human_path2/follow", $"../human_path3/follow", $"../human_path4/follow", $"../human_path5/follow", $"../human_path6/follow"].pick_random()

@onready var chasing:bool = false
@onready var grabbing = false
var curve_path = null
var	min_distance = 0
# 0 SPAWNED / 1 GOING CHOSEN PATH / 2 WALK BACK /  3 Spawn back
var point_index:int = 0
@onready var player:CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var grab_sfx:AudioStreamPlayer2D = $"../sfx/grab_sfx"

@onready var animation_tree:AnimationTree = $AnimationTree

func _ready():
	animation_tree.active = true

func change_path_status():
	last_pos = global_position
	in_path_line = false

func get_back_spawn():
	min_distance = 0
	if get_parent().get_node("human"):
		get_parent().get_node("human").reparent(path_spawn, true)
		path_index = 3

func _process(delta):
	update_animation_parameters()
	var current_position = global_position
	direction = (current_position - previous_position).normalized()
	previous_position = current_position

func _physics_process(delta):
	if !chopping_tree:
		if chasing:
			if in_path_line:
				change_path_status()
			else:
				if global_position.distance_to(player.global_position) < 31 and !player.grabbed:
					player.grabbed = true
					grabbing = true
					player.global_position = global_position
					grab_sfx.play()
				elif global_position.distance_to(player.global_position) < 31 and !grabbing and player.grabbed:
					chasing = false
				elif grabbing:
					velocity = Vector2.ZERO
					$VisionCone2D.look_at(player.global_position)
					$VisionCone2D.rotation -= PI/2
				else:
					target_position = (player.global_position - global_position).normalized()
					velocity = Vector2(target_position * 100)
					$VisionCone2D.look_at(player.global_position)
					$VisionCone2D.rotation -= PI/2
					move_and_slide()
		elif in_path_line:
			curve_path = get_parent().get_parent()
			for point in range(curve_path.curve.point_count):
				if !min_distance:
					min_distance = global_position.distance_to(curve_path.curve.get_point_position(point))
				if global_position.distance_to(curve_path.curve.get_point_position(point)) < min_distance:
					min_distance = global_position.distance_to(curve_path.curve.get_point_position(point))
					point_index = point
			if timer_inactive and path_spawn.progress_ratio != 1:
				if point_index+1 < curve_path.curve.point_count:
					$VisionCone2D.look_at(Vector2(curve_path.curve.get_point_position(point_index+1).x, curve_path.curve.get_point_position(point_index+1).y))
				else:
					$VisionCone2D.look_at(Vector2(curve_path.curve.get_point_position(point_index).x, curve_path.curve.get_point_position(point_index).y))
				$VisionCone2D.rotation -= PI/2
				path_spawn.progress_ratio += delta*0.3
			elif timer_inactive and path_spawn.progress_ratio == 1:
				timer_inactive = false
				get_parent().get_parent().get_node("wait_to_keep_walking").start()
			elif path_index == 1 and chosen_path.progress_ratio != 1:
				if point_index+1 < curve_path.curve.point_count:
					$VisionCone2D.look_at(Vector2(curve_path.curve.get_point_position(point_index+1).x-20, curve_path.curve.get_point_position(point_index+1).y))
				else:
					$VisionCone2D.look_at(Vector2(curve_path.curve.get_point_position(point_index).x-20, curve_path.curve.get_point_position(point_index).y))
				$VisionCone2D.rotation -= PI/2
				chosen_path.progress_ratio += delta*0.08
			elif path_index == 1 and chosen_path.progress_ratio == 1:
				min_distance = 0
				path_index = 2
			elif path_index == 2 and chosen_path.progress_ratio != 0:
				if point_index > 0:
					$VisionCone2D.look_at(Vector2(curve_path.curve.get_point_position(point_index-1).x-20, curve_path.curve.get_point_position(point_index-1).y))
				else:
					$VisionCone2D.look_at(Vector2(curve_path.curve.get_point_position(point_index).x-20, curve_path.curve.get_point_position(point_index).y))
				$VisionCone2D.rotation -= PI/2
				chosen_path.progress_ratio -= delta*0.06
			elif path_index == 2 and chosen_path.progress_ratio == 0:
				get_back_spawn()
			elif path_index == 3 and path_spawn.progress_ratio != 0:
				if point_index > 0:
					$VisionCone2D.look_at(Vector2(curve_path.curve.get_point_position(point_index-1).x, curve_path.curve.get_point_position(point_index-1).y))
				else:
					$VisionCone2D.look_at(Vector2(curve_path.curve.get_point_position(point_index).x, curve_path.curve.get_point_position(point_index).y))
				$VisionCone2D.rotation += PI
				path_spawn.progress_ratio -= delta*0.2
			elif path_index == 3 and path_spawn.progress_ratio == 0:
				call_deferred("free")
		else:
			target_position = (last_pos - global_position).normalized()
			if global_position.distance_to(last_pos) < 1:
				in_path_line = true
			else:
				velocity = Vector2(target_position*40)
				$VisionCone2D.look_at(last_pos)
				$VisionCone2D.rotation -= PI/2
				move_and_slide()

func update_animation_parameters():
	velocity = direction*10
	if velocity == Vector2.ZERO:
		animation_tree["parameters/conditions/chop"] = false
		animation_tree["parameters/conditions/chase"] = false
		animation_tree["parameters/conditions/axe_hold"] = false
		animation_tree["parameters/conditions/walk"] = false
		animation_tree["parameters/conditions/wood_hold"] = false
		if path_index > 0 and !chopping_tree:
			animation_tree["parameters/conditions/axe_idle"] = true
			animation_tree["parameters/conditions/idle"] = false
		else:
			animation_tree["parameters/conditions/idle"] = true
			animation_tree["parameters/conditions/axe_idle"] = false
	else:
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/axe_idle"] = false
		if chasing:
			animation_tree["parameters/conditions/chase"] = true
			animation_tree["parameters/conditions/walk"] = false
			animation_tree["parameters/conditions/axe_hold"] = false
		elif !chasing and path_index == 1:
			animation_tree["parameters/conditions/axe_hold"] = true
			animation_tree["parameters/conditions/chase"] = false
			animation_tree["parameters/conditions/walk"] = false
		elif !chasing and path_index > 1:
			if chopping_tree and !has_wood:
				animation_tree["parameters/conditions/chop"] = true
				animation_tree["parameters/conditions/axe_hold"] = false
				animation_tree["parameters/conditions/chase"] = false
				animation_tree["parameters/conditions/walk"] = false
			if has_wood:
				animation_tree["parameters/conditions/chop"] = false
				animation_tree["parameters/conditions/chase"] = false
				animation_tree["parameters/conditions/wood_hold"] = true
				animation_tree["parameters/conditions/axe_hold"] = false
				animation_tree["parameters/conditions/walk"] = false
			else:
				animation_tree["parameters/conditions/chase"] = false
				animation_tree["parameters/conditions/axe_hold"] = true
				animation_tree["parameters/conditions/wood_hold"] = false
				animation_tree["parameters/conditions/walk"] = false
		else:
			animation_tree["parameters/conditions/chase"] = false
			animation_tree["parameters/conditions/walk"] = true
			animation_tree["parameters/conditions/axe_hold"] = false
	if direction != Vector2.ZERO:
		animation_tree["parameters/chase/blend_position"] = direction
		animation_tree["parameters/idle/blend_position"] = direction
		animation_tree["parameters/walk/blend_position"] = direction
		animation_tree["parameters/chop/blend_position"] = direction
		animation_tree["parameters/axe_idle/blend_position"] = direction
		animation_tree["parameters/axe_hold/blend_position"] = direction
		animation_tree["parameters/wood_hold/blend_position"] = direction
		if  direction.x < 0 and direction.x <= direction.y:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false

func _on_vision_cone_area_body_entered(body):
	if !chopping_tree and path_index < 2:
		chasing = true
		player.is_being_chased = true

func _on_vision_cone_area_body_exited(body):
	chasing = false
	player.is_being_chased = false

func _on_colision_area_entered(area):
	# THE IF ARE THE REASON THE HUMAN STOP WHEN COLIDE, IDK WHY
	if !chopping_tree and !area.owner.get_node("gather_area/CollisionShape2D_pick").disabled:
		path_index = 4
		chasing = false
		chopping_tree = area.owner
		chopping_tree.get_node("gather_area/CollisionShape2D_pick").set_deferred("disabled", true)
		human_node.get_node("chopping").start()

func _on_chopping_timeout():
	min_distance = 0
	path_index = 2
	$VisionCone2D.visible = false
	$grab_area.disabled = true

func _on_wait_to_keep_walking_timeout():
	reparent(chosen_path, true)
	min_distance = 0
	path_index = 1

func _on_animation_tree_animation_finished(anim_name):
	if anim_name in ["chop_down", "chop_up" , "chop_side"]:
		animation_tree["parameters/conditions/chop"] = false
		animation_tree["parameters/conditions/axe_idle"] = true
		if chopping_tree != null:
			chopping_tree.get_node("AnimationPlayer").play(["fall_left", "fall_right"].pick_random())
		has_wood = true
		grab_sfx.get_parent().get_child(randi_range(1, 2)).play()
