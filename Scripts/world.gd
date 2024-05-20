extends Node2D

var options_scene = preload("res://Assets/UI/menu/options.tscn")
var user_prefs: UserPreferences
@onready var trees = $trees
@onready var gamover = $gamover

func _ready():
	get_tree().paused = false
	user_prefs = UserPreferences.load_or_create()
	if user_prefs:
		AudioServer.set_bus_volume_db(0, linear_to_db(user_prefs.master_volume))
		AudioServer.set_bus_volume_db(1, linear_to_db(user_prefs.music_volume))
		AudioServer.set_bus_volume_db(2, linear_to_db(user_prefs.sfx_volume))
	BgMenuMusic.playing = false
	BgGameIntro.playing = true
	BgSucessMusic.playing = false

func _process(_delta):
	$UI/Control/BoxContainer/trees_left.text = str(trees.get_child_count())
	if trees.get_child_count() == 0 and $UI.visible or trees.get_child_count()*4 < int(30-%player.current_progress) and $UI.visible:
		get_tree().paused = true
		$UI.visible = false
		user_prefs = UserPreferences.load_or_create()
		$gamover/MarginContainer/VBoxContainer/death_reason.text = "Discovered the human desire for wood"
		if %player.current_progress > user_prefs.max_score:
			$gamover/MarginContainer/VBoxContainer/bestscore.text = "Your max score was: "+str(%player.current_progress)
			user_prefs.max_score = %player.current_progress
			user_prefs.save()
		else:
			$gamover/MarginContainer/VBoxContainer/bestscore.text = "Your max score was: "+str(user_prefs.max_score)
		$gamover.visible = true
		$gamover/AnimationPlayer.play("fade_out")
	if Input.is_action_just_pressed("esc"):
		if has_node("/root/World/options"):
			get_tree().paused = false
			get_node("/root/World/options").call_deferred("free")
		else:
			get_tree().paused = true
			add_child(options_scene.instantiate())

func _on_texture_button_pressed():
	get_tree().paused = true
	add_child(options_scene.instantiate())


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fadeout":
		get_tree().change_scene_to_file("res://Scenes/sucess.tscn")
