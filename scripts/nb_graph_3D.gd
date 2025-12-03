extends Node3D

# Just to connect graph node

@export var value_dict: Dictionary[String, float] = {}

signal updateGraph

func _ready() -> void:
	update()

func update():
	updateGraph.emit()
