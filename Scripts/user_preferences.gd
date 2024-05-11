class_name UserPreferences extends Resource

@export_range(0, 1, 0.001) var master_volume: float = 1.0
@export_range(0, 1, 0.001) var music_volume: float = 1.0
@export_range(0, 1, 0.001) var sfx_volume: float = 1.0

func save() -> void:
	ResourceSaver.save(self, "user://user_prefs.tres")

static func load_or_create() -> UserPreferences:
	var res: UserPreferences = load("user://user_prefs.tres") as UserPreferences
	if !res:
		res = UserPreferences.new()
	return res

