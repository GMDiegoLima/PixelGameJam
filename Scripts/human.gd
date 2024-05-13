extends Path2D

var timer_inactive = true
var can_path = false
@onready var chosen_path = get_node("human_path"+str(randi_range(1, 3))+"/follow")

func start_time():
	if timer_inactive:
		timer_inactive = false
		$wait_to_keep_walking.start()

func _process(delta):
	if timer_inactive and $human_first_path.progress_ratio != 1:
		$human_first_path.progress_ratio += delta*0.5
	elif !timer_inactive and $human_first_path.progress_ratio == 1:
		start_time()
	elif can_path and chosen_path.progress_ratio != 1:
		chosen_path.progress_ratio += delta*0.5

func _on_wait_to_keep_walking_timeout():
	$human_first_path/human.reparent(chosen_path, true)
	can_path = true
	print(chosen_path)
