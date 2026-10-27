extends Node3D

const HOLE_SCENE := preload("res://scenes/hole.tscn")

@export var antique_pool: Array[AntiqueData] = []
@export var antique_count: int = 30
@export var spawn_half_size: float = 25.0
@export var dig_radius: float = 1.0
@export var show_buried: bool = false

@onready var player: Player = $Player
@onready var buried_antiques: Node3D = $BuriedAntiques
@onready var message_label: Label = $CanvasLayer/MessageLabel
@onready var message_timer: Timer = $MessageTimer

func _ready() -> void:
	player.dug.connect(_on_player_dug)
	player.bag_full.connect(_on_player_bag_full)
	message_timer.timeout.connect(message_label.hide)
	message_label.hide()
	bury_antiques()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func bury_antiques() -> void:
	if antique_pool.is_empty():
		push_error("Antique pool is empty broooo!!!")
		return
	
	for i in antique_count:
		var spot := Marker3D.new()
		buried_antiques.add_child(spot)
		spot.position = Vector3(
			randf_range(-spawn_half_size, spawn_half_size),
			0,
			randf_range(-spawn_half_size, spawn_half_size)
		)
		spot.set_meta("antique", pick_random_antique())
		if show_buried:
			var debug_mesh := MeshInstance3D.new()
			var stick := BoxMesh.new()
			stick.size = Vector3(0.2, 1.0, 0.2)
			debug_mesh.mesh = stick
			spot.add_child(debug_mesh)

func pick_random_antique() -> AntiqueData:
	var total_weight := 0
	for antique in antique_pool:
		total_weight += antique.rarity_weight
	var roll := randi_range(1, total_weight)
	for antique in antique_pool:
		roll -= antique.rarity_weight
		if roll <= 0:
			return antique
	return antique_pool[0]

func _on_player_dug(dig_position: Vector3) -> void:
	var hole: Node3D = HOLE_SCENE.instantiate()
	add_child(hole)
	hole.global_position = dig_position + Vector3.UP * 0.01
	
	var found := find_antique_near(dig_position)
	if found:
		var antique: AntiqueData = found.get_meta("antique")
		if player.inventory.add_item(antique):
			found.queue_free()
			show_message("You found a %s antique !!!! LESS GOOOO !!!!" % antique.display_name)
		else:
			show_message("Found a %s, but your bag has no more room brehh! But its still buried here" % antique.display_name)
	else:
		show_message("Nothing here..... brehhhhh")
		
func find_antique_near(dig_position: Vector3) -> Node3D:
	var flat_dig := Vector3(dig_position.x, 0, dig_position.z)
	for spot in buried_antiques.get_children():
		if spot.position.distance_to(flat_dig) <= dig_radius:
			return spot
	return null
	
func show_message(text: String) -> void:
	message_label.text = text
	message_label.show()
	message_timer.start()

func _on_player_bag_full() -> void:
	show_message("Your bag is full broo!! Go sell it in the shop !!")
