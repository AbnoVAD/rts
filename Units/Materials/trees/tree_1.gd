extends StaticBody2D

#----------------------------------------
#States
#----------------------------------------
enum TreeState{
	IDLE,
	CHOPPING,
	CHOPPED,
	GROWING
}

var state:TreeState=TreeState.IDLE
@export var life=3
