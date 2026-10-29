class_name Inventory
extends Node

signal changed

const MAX_SLOTS := 5
const MAX_STACK := 3

var slots : Array[Dictionary] = []

func is_full() -> bool:
	if slots.size() < MAX_SLOTS:
		return false
	for slot in slots:
		if slot["count"] < MAX_STACK:
			return false
	return true
	
func add_item(item: AntiqueData) -> bool:
	for slot in slots:
		if slot["antique"] == item and slot["count"] < MAX_STACK:
			slot["count"] += 1
			changed.emit()
			return true
			
	if slots.size() >= MAX_SLOTS:
		return false
		
	slots.append({"antique": item, "count": 1})
	changed.emit()
	return true

func take_all() -> Array[Dictionary]:
	var taken: Array[Dictionary] = slots
	slots = []
	changed.emit()
	return taken
