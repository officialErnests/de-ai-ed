extends Node3D

@export var value_dict: Dictionary[String, float] = {}

signal updateGraph

func _ready() -> void:
	update()

func update():
	updateGraph.emit()
