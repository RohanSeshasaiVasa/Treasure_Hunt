extends Control

func _ready() -> void:
	%Level1Button.pressed.connect(_load_level.bind(1))
	%Level2Button.pressed.connect(_load_level.bind(2))
	%Level3Button.pressed.connect(_load_level.bind(3))
	%BackButton.pressed.connect(_on_back_pressed)
	
func _load_level(level_number: int) -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level_%d.tscn" % level_number)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
