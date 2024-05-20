extends Node2D

func _ready():
	$UI/AnimationPlayer.play("fadein")
	$Camera/AnimationPlayer.play("camera_follow")
	BgSucessMusic.playing = true

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fadein":
		$UI/congratz.visible = true
		$UI/VBoxContainer.visible = true
		$UI/AnimationPlayer.play("congratz")

func _on_button_pressed():
	get_tree().change_scene_to_file("res://Assets/UI/menu/menu.tscn")

func _on_end_of_the_walk_body_entered(body):
	body.call_deferred("free")
