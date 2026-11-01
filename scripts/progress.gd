extends Node

const SAVE_PATH := "user://progress.cfg"

var unlocked_level: int = 1

func _ready() -> void:
	load_progress()
	
func is_unlocked(level: int) -> bool:
	return level <= unlocked_level

func complete_level(level: int) -> void:
	if level + 1 > unlocked_level:
		unlocked_level = level +1
		save_progress()
		
func save_progress() -> void:
	var config := ConfigFile.new()
	config.set_value("progress", "unlocked_level", unlocked_level)
	config.save(SAVE_PATH)

func load_progress() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		unlocked_level = config.get_value("progress", "unlocked_level", 1)
