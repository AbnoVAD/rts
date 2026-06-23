extends "res://Unit_buildings/House2/house2.gd"

func _ready() -> void:
	super._ready()
	add_to_group("warehouse")

func can_accept_deposit() -> bool:
	return state == STATE_IDLE

func deposit_worker_resources(payload:Dictionary) -> bool:
	if not can_accept_deposit() or payload.is_empty():
		return false

	var wood:=int(payload.get("wood",0))
	var gold:=int(payload.get("gold",0))
	var meat:=int(payload.get("meat",0))

	if wood>0:
		Global.add_wood(wood)
	if gold>0:
		Global.add_gold(gold)
	if meat>0:
		Global.add_meat(meat)
	return true

func get_worker_deposit_position() -> Vector2:
	if is_instance_valid(marker_1):
		return marker_1.global_position
	return global_position
