extends Node3D

const HOLE_SCENE := preload("res://scenes/hole.tscn")

@export_group("level Rules")
@export var level_number: int = 1
@export var target_value: int = 50000
@export var time_limit: float = 300.0

@export var antique_pool: Array[AntiqueData] = []
@export var antique_count: int = 30
@export var spawn_half_size: float = 25.0
@export var dig_radius: float = 1.0
@export var show_buried: bool = false
@export_group("Island")
@export var shore_radius: float = 32.0
@export var wall_segments: int = 48

var total_earned: int = 0

@onready var player: Player = $Player
@onready var shopkeeper: Shopkeeper = $Shopkeeper
@onready var buried_antiques: Node3D = $BuriedAntiques
@onready var message_label: Label = $CanvasLayer/MessageLabel
@onready var message_timer: Timer = $MessageTimer
@onready var total_label: Label = $CanvasLayer/TotalLabel
@onready var level_timer: Timer = %LevelTimer
@onready var timer_label: Label = %TimerLabel
@onready var result_panel: PanelContainer = %ResultPanel
@onready var result_title: Label = %ResultTitle
@onready var result_details: Label = %ResultDetailes
@onready var boundaries: StaticBody3D = $Boundaries

func _ready() -> void:
	player.dug.connect(_on_player_dug)
	player.bag_full.connect(_on_player_bag_full)
	shopkeeper.appraised.connect(_on_shopkeeper_appraised)
	message_timer.timeout.connect(message_label.hide)
	level_timer.timeout.connect(_on_time_up)
	%RetryButton.pressed.connect(_on_retry_pressed)
	%LevelSelectButton.pressed.connect(_on_level_select_pressed)
	
	message_label.hide()
	result_panel.hide()
	update_total_label()
	build_walls()
	bury_antiques()
	level_timer.start(time_limit)

func _process(_delta: float) -> void:
	var seconds_left := ceili(level_timer.time_left)
	var minutes := floori(seconds_left /60.0)
	var seconds := seconds_left%60
	timer_label.text = "%d:%02d" % [minutes, seconds]
	timer_label.modulate = Color.RED if seconds_left <= 60 else Color.WHITE

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
		var point := random_island_point()
		while is_near_tree(point):
			point = random_island_point()
		spot.position = point
		spot.set_meta("antique", pick_random_antique())
		if show_buried:
			var debug_mesh := MeshInstance3D.new()
			var stick := BoxMesh.new()
			stick.size = Vector3(0.2, 1.0, 0.2)
			debug_mesh.mesh = stick
			spot.add_child(debug_mesh)
			var name_tag := Label3D.new()
			name_tag.text = spot.get_meta("antique").display_name
			name_tag.font_size = 48
			name_tag.position = Vector3.UP * 0.8
			name_tag.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			spot.add_child(name_tag)

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
	
func _on_player_bag_full() -> void:
	show_message("Your bag is full broo!! Go sell it in the shop !!")

func _on_shopkeeper_appraised(results: Array) -> void:
	if results.is_empty():
		show_message("Bro you have nothing with you> Go dig something up brehh !!")
		return
	var lines: Array[String] = []
	var earned := 0
	for result in results:
		var prices: Array[String] = []
		for value in result["values"]:
			prices.append(format_rupees(value))
			earned += value
		lines.append("%s: %s!" % [result["name"], ", ". join(prices)])
	
	total_earned += earned
	update_total_label()
	lines.append("You earned %s!" % format_rupees(earned))
	show_message("\n".join(lines), 5.0)
	if total_earned >= target_value:
		end_level(true)
	
func _on_time_up() -> void:
	end_level(true)
	
func end_level(won: bool) -> void:
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if won:
		result_title.text = "Level %d Complete !! hurray !!" % level_number
		result_details.text = "You earned %s with %s left on the clock. Damn bro!" % [format_rupees(total_earned), timer_label.text]
	else:
		result_title.text = "Time's Up !"
		result_details.text = "You earned %s of %s. L brehh." % [format_rupees(total_earned), format_rupees(target_value)]
	result_panel.show()
	
func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_level_select_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func update_total_label() -> void:
	total_label.text = "%s / %s" % [format_rupees(total_earned), format_rupees(target_value)]

func format_rupees(amount: int) -> String:
	var digits := str(amount)
	if digits.length() <= 3:
		return "₹" + digits
	var result := digits.right(3)
	var rest := digits.left(digits.length() - 3)
	while rest.length()>2:
		result = rest.right(2) + ", " + result
		rest = rest.left(rest.length() - 2)
	return "₹" + rest + "," + result



func show_message(text: String, duration: float = 1.5) -> void:
	message_label.text = text
	message_label.show()
	message_timer.start(duration)


func build_walls() -> void:
	var segment_width := TAU * shore_radius /wall_segments *1.2
	for i in wall_segments:
		var angle := TAU*i/wall_segments
		var box := BoxShape3D.new()
		box.size = Vector3(segment_width, 10.0, 1.0)
		var segment := CollisionShape3D.new()
		segment.shape = box
		segment.position = Vector3(sin(angle), 0, cos(angle)) * (shore_radius + 0.5) + Vector3.UP* 5.0
		segment.rotation.y = angle
		boundaries.add_child(segment)

func random_island_point() -> Vector3:
	var angle := randf() *TAU
	var distance := sqrt(randf()) * (shore_radius -1.0)
	return Vector3(sin(angle) * distance, 0, cos(angle) *distance)
	
func is_near_tree(point: Vector3) -> bool:
	for tree_node in get_tree().get_nodes_in_group("trees"):
		var tree_spot := Vector3(tree_node.global_position.x, 0, tree_node.global_position.z)
		if tree_spot.distance_to(point)< 1.5:
			return true
	return false
