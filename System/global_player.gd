extends Node

var pawns:Array=[]
var active_player:Node=null
var active_player_position: Vector2
var pawn_all_dead:bool=true

var castle_position=Vector2.ZERO
var camera_shake_func: Callable=Callable()

func _is_valid_pawn(pawn:Variant) -> bool:
	return pawn is Node and is_instance_valid(pawn)

func _prune_invalid_pawns() -> void:
	for i in range(pawns.size() - 1, -1, -1):
		if not _is_valid_pawn(pawns[i]):
			pawns.remove_at(i)
	if active_player and not is_instance_valid(active_player):
		active_player=null

#-------------------------------------
#Register the pawn
#-------------------------------------
func register_pawn(pawn:Node)->void:
	_prune_invalid_pawns()
	if not _is_valid_pawn(pawn):
		return
	if pawn in pawns:
		return
	pawns.append(pawn)
	
	if pawn.has_signal("died"):
		pawn.died.connect(_on_pawn_died)
		
	_update_pawn_state()
	if pawns.size()==1:
		set_active_pawn(pawn)


#-------------------------------------
#signal callback
#-------------------------------------
func _on_pawn_died(pawn:Node)->void:
	unregistered_pawn(pawn)

func unregistered_pawn(pawn:Node)-> void:
	_prune_invalid_pawns()
	if pawn not in pawns:
		return
	var was_active:=pawn==active_player
	pawns.erase(pawn)
	
	_update_pawn_state()
	if was_active:
		activate_next_pawn()

#-------------------------------------
#active pawn
#-------------------------------------
func set_active_pawn(pawn:Object=null)-> void:
	_prune_invalid_pawns()
	if not _is_valid_pawn(pawn):
		pawn=null
	if active_player and active_player!=pawn:
		if active_player.has_method("deactivate"):
			active_player.deactivate()
	active_player=pawn as Node
	if active_player and active_player.has_method("activate_from_global"):
		active_player.activate_from_global()

func activate_next_pawn()-> void:
	_prune_invalid_pawns()
	if pawns.is_empty():
		active_player=null
		return
	set_active_pawn(pawns[0])

func _update_pawn_state()-> void:
	pawn_all_dead=pawns.is_empty()
	

func get_pawn_count()->int:
	return pawns.size()
