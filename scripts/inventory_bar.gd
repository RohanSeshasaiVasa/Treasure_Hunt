extends HBoxContainer

@onready var inventory: Inventory = %Inventory

func _ready() -> void:
	inventory.changed.connect(refresh)
	refresh()
	
func refresh() -> void:
	var slot_nodes := get_children()
	for i in slot_nodes.size():
		var label: Label = slot_nodes[i].get_node("NameLabel")
		if i < inventory.slots.size():
			var slot: Dictionary = inventory.slots[i]
			var text: String = slot["antique"].display_name
			if slot["count"]>1:
				text+= "\nx%d" % slot["count"]
			label.text = text
		else:
			label.text = ""
