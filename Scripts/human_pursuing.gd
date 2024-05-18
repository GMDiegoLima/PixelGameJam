extends CharacterBody2D

@onready var target_position = null
var last_pos:Vector2 = Vector2.ZERO

var chopping_tree = null
var timer_inactive:bool = true
var can_path:int = 0
var in_path_line:bool = true
@onready var human_node = get_parent()
@onready var path_spawn = human_node.get_node("human_spawned/follow")
@onready var chosen_path = [$"../human_path1/follow", $"../human_path2/follow", $"../human_path3/follow", $"../human_path4/follow", $"../human_path5/follow", $"../human_path6/follow"].pick_random()

@onready var chasing:bool = false
var curve_path = null
var	min_distance = 0
var point_index = 0
@onready var player = get_tree().get_first_node_in_group("player")
@onready var grab_sfx = $"../sfx/grab_sfx"

#func _ready():
	#print(human_node.get_node("human_spawned/wait_to_keep_walking").is_stopped())

func change_path_status():
	last_pos = global_position
	in_path_line = false

func get_back_spawn():
	min_distance = 0
	can_path = 3
	if chosen_path.get_node("human"):
		chosen_path.get_node("human").reparent(path_spawn, true)

func _physics_process(delta):
	# IMPORTANT FOR ANIMATION TREE VECTOR
	#direction = Vector2(cos(deg_to_rad(rotation_degrees)), sin(deg_to_rad(rotation_degrees)))
	if !chopping_tree:
		if chasing:
			if in_path_line:
				change_path_status()
			else:
				if global_position.distance_to(player.global_position) < 31:
					print("YOU GOT GRABBED !")
					player.global_position = global_position
					player.grabbed = true

					# DO SOMETHING AFTER GRAB
					#grab_sfx.play()
					# get_tree().change_scene_to_file("res://Scenes/world.tscn")
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
				#print("SPAWN GOING: ", point_index)
				$VisionCone2D.rotation -= PI/2
				path_spawn.progress_ratio += delta*0.3
			elif can_path == 1 and chosen_path.progress_ratio != 1:
				if point_index+1 < curve_path.curve.point_count:
					$VisionCone2D.look_at(Vector2(curve_path.curve.get_point_position(point_index+1).x-20, curve_path.curve.get_point_position(point_index+1).y))
					#print("COORD: ", Vector2(curve_path.curve.get_point_position(point_index+1).x-20, curve_path.curve.get_point_position(point_index+1).y), " CHOSEN PATH", chosen_path.get_parent().name, " CURVE: ", curve_path.name, " CHOSEN PATH GOING: ", point_index+1)
				else:
					$VisionCone2D.look_at(Vector2(curve_path.curve.get_point_position(point_index).x-20, curve_path.curve.get_point_position(point_index).y))
					#print("COORD: ", Vector2(curve_path.curve.get_point_position(point_index+1).x-20, curve_path.curve.get_point_position(point_index+1).y), "CHOSEN PATH", chosen_path.get_parent().name, " CURVE: ", curve_path.name, " CHOSEN PATH GOING: ", point_index)
				$VisionCone2D.rotation -= PI/2
				chosen_path.progress_ratio += delta*0.05
			elif can_path == 1 and chosen_path.progress_ratio == 1:
				min_distance = 0
				can_path = 2
			elif can_path == 2 and chosen_path.progress_ratio != 0:
				if point_index > 0:
					$VisionCone2D.look_at(Vector2(curve_path.curve.get_point_position(point_index-1).x-20, curve_path.curve.get_point_position(point_index-1).y))
				else:
					$VisionCone2D.look_at(Vector2(curve_path.curve.get_point_position(point_index).x-20, curve_path.curve.get_point_position(point_index).y))
				$VisionCone2D.rotation -= PI/2
				chosen_path.progress_ratio -= delta*0.05
			elif can_path == 2 and chosen_path.progress_ratio == 0:
				get_back_spawn()
			elif can_path == 3 and path_spawn.progress_ratio != 0:
				if point_index > 0:
					$VisionCone2D.look_at(Vector2(curve_path.curve.get_point_position(point_index-1).x, curve_path.curve.get_point_position(point_index-1).y))
				else:
					$VisionCone2D.look_at(Vector2(curve_path.curve.get_point_position(point_index).x, curve_path.curve.get_point_position(point_index).y))
				$VisionCone2D.rotation += PI
				path_spawn.progress_ratio -= delta*0.1
			elif can_path == 3 and path_spawn.progress_ratio == 0:
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

func _on_vision_cone_area_body_entered(body):
	player.is_being_chased = true
	chasing = true

func _on_vision_cone_area_body_exited(body):
	player.is_being_chased = false
	chasing = false

func _on_colision_area_entered(area):
	# THE IF ARE THE REASON THE HUMAN STOP WHEN COLIDE, IDK WHY
	if !chopping_tree and !area.owner.get_node("gather_area/CollisionShape2D_pick").disabled:
		chopping_tree = area.owner
		chopping_tree.get_node("gather_area/CollisionShape2D_pick").disabled = true
		human_node.get_node("chopping").start()

func _on_colision_area_exited(area):
	chopping_tree = null

func _on_chopping_timeout():
	if chopping_tree:
		chopping_tree.call_deferred("free")
	min_distance = 0
	can_path = 2

func _on_wait_to_keep_walking_timeout():
	timer_inactive = false
	human_node.get_node("human_spawned/follow/human").reparent(chosen_path, true)
	min_distance = 0
	can_path = 1
