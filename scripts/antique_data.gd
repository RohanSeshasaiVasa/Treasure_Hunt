class_name AntiqueData
extends Resource

@export var display_name: String = "Antique"
@export var icon: Texture2D
@export var min_value: int = 1000
@export var max_value: int = 2000
@export_range(1, 100) var rarity_weight: int = 10

func roll_value() -> void:
	return snappedi(randi_range(min_value, max_value), 100)
