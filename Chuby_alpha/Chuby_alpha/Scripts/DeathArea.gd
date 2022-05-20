extends "res://Scripts/Pickable.gd"

class_name DeathArea

func pick_up():
	.pick_up()
	queue_free()

