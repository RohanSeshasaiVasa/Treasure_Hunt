extends Control

func _ready() -> void:
	var level_number := 1
	for button in %LevelButtons.get_children():
		button.pressed.connect(_load_level.bind(level_number))
		button.disabled = not Progress.is_unlocked(level_number)
		level_number += 1
	%BackButton.pressed.connect(_on_back_pressed)
	
func _load_level(level_number: int) -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level_%d.tscn" % level_number)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
