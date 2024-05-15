extends Node2D

var timer_inactive = true
# 0 spawn path, 1 the chosen path, 2 walk back, 3 spawn path and enter the fabric
var can_path = 0
var chopping_tree = null

@onready var path_spawn = $human_spawned/follow
@onready var timer_spawn = $human_spawned/wait_to_keep_walking
@onready var chosen_path = [$human_path1/follow, $human_path2/follow, $human_path3/follow].pick_random()

func _ready():
	$human.reparent(path_spawn, true)

func start_time():
	if timer_inactive:
		timer_inactive = false
		timer_spawn.start()

func get_back_spawn():
	can_path = 3
	if chosen_path.get_node("human"):
		chosen_path.get_node("human").reparent(path_spawn, true)

func _process(delta):
	if !chopping_tree:
		if timer_inactive and path_spawn.progress_ratio != 1:
			path_spawn.progress_ratio += delta*0.4
		elif timer_inactive and path_spawn.progress_ratio == 1:
			start_time()
		elif can_path == 1 and chosen_path.progress_ratio != 1:
			chosen_path.progress_ratio += delta*0.25
		elif can_path == 1 and chosen_path.progress_ratio == 1:
			can_path = 2
		elif can_path == 2 and chosen_path.progress_ratio != 0:
			chosen_path.progress_ratio -= delta*0.25
		elif can_path == 2 and chosen_path.progress_ratio == 0:
			get_back_spawn()
		elif can_path == 3 and path_spawn.progress_ratio != 0:
			path_spawn.progress_ratio -= delta*0.4
		elif can_path == 3 and path_spawn.progress_ratio == 0:
			call_deferred("free")

func _on_wait_to_keep_walking_timeout():
	$human_spawned/follow/human.reparent(chosen_path, true)
	can_path = 1

func _on_colision_area_entered(area):
	$chopping.start()
	# THE IF ARE THE REASON THE HUMAN STOP WHEN COLIDE, IDK WHY
	if !chopping_tree:
		chopping_tree = area.owner

func _on_chopping_timeout():
	if chopping_tree:
		chopping_tree.call_deferred("free")
	can_path = 2
