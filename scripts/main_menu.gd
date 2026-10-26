extends Control

func _ready() -> void:
	%AboutPanel.hide()
	%PlayButton.pressed.connect(_on_play_pressed)
	%AboutButton.pressed.connect(_on_about_pressed)
	%CloseButton.pressed.connect(_on_close_pressed)
	%QuitButton.pressed.connect(_on_quit_pressed)


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")
	
func _on_about_pressed() -> void:
	%AboutPanel.show()
	
func _on_close_pressed() -> void:
	%ABoutPanel.hide()
	
func _on_quit_pressed() -> void:
	get_tree().quit()
