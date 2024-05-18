extends Node2D

var timer_inactive = true
# 0 spawn path, 1 the chosen path, 2 walk back, 3 spawn path and enter the fabric
var can_path = 0
var chopping_tree = null

var current_path = null
var target_position = null

@onready var path_spawn = $human_spawned/follow
@onready var timer_spawn = $human_spawned/wait_to_keep_walking
@onready var chosen_path = [$human_path1/follow, $human_path2/follow, $human_path3/follow, $human_path4/follow, $human_path5/follow].pick_random()
@onready var player = get_tree().get_first_node_in_group("player")

var direction:Vector2 = Vector2.ZERO

func _ready():
	$human.reparent(path_spawn, true)

func start_time():
	if timer_inactive:
		timer_inactive = false
		timer_spawn.start()

func _process(delta):
	if timer_inactive and path_spawn.progress_ratio == 1:
		start_time()

func _on_wait_to_keep_walking_timeout():
	current_path = chosen_path
	$human_spawned/follow/human.reparent(chosen_path, true)
	can_path = 1
