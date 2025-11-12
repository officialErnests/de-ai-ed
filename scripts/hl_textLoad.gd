extends Node

@export var text_to_update: MeshInstance3D
var parent_nb: Node

func _ready() -> void:
	parent_nb = get_parent()
	parent_nb.updateSignal.connect(update)

func update():
	text_to_update.mesh.text = parent_nb.value
