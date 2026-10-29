class_name Shopkeeper
extends StaticBody3D

signal appraised(results: Array)

var nearby_player: Player = null

@onready var talk_zone: Area3D = $TalkZone
@onready var prompt: Label3D = $Prompt

func _ready() -> void:
	prompt.hide()
	talk_zone.body_entered.connect(_on_body_entered)
	talk_zone.body_exited.connect(_on_body_exited)
	
func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		nearby_player = body as Player 
		prompt.show()

func _on_body_exited(body: Node3D) -> void:
	if body == nearby_player:
		nearby_player = null
		prompt.hide()
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and nearby_player != null:
		appraise(nearby_player.inventory)

func appraise(inventory: Inventory) -> void:
	var results: Array = []
	for slot in inventory.take_all():
		var antique: AntiqueData = slot["antique"]
		var values: Array[int] = []
		for i in slot["count"]:
			values.append(antique.roll_value())
		results.append({"name": antique.display_name, "values": values})
	appraised.emit(results)
