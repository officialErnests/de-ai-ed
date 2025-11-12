class_name NB_Label3D extends Node3D

@export var value: String

signal updateSignal

func _ready() -> void:
	updateSignal.emit()

func update() -> void:
	updateSignal.emit()