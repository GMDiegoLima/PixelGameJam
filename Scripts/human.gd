extends Node2D

@onready var path_spawn = $human_spawned/follow
func _ready():
	$human.reparent(path_spawn, true)
