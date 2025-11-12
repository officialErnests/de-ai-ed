extends Node

@export_category("Values")
@export var segment_size := Vector2.ONE
@export var z_size: float = 0.1
@export var x_padding: float = 0.1
@export_category("X axis")
@export var x_axis_line: MeshInstance3D
@export var x_axis_head: MeshInstance3D
@export var x_axis_markins: Node3D
@export_category("Y axis")
@export var y_axis_line: MeshInstance3D
@export var y_axis_head: MeshInstance3D
@export var y_axis_markins: Node3D
@export_category("Misc")
@export var text_packed_scene: PackedScene
@export var value_parent: Node3D
@export var graph_material: BaseMaterial3D


var graph: Node3D

func _ready() -> void:
	graph = get_parent()
	graph.updateGraph.connect(updateGraph)

func updateGraph() -> void:
	var value_dict: Dictionary[String, float] = graph.value_dict
	var graph_size_x: float = value_dict.size()

	x_axis_line.mesh.size.x = graph_size_x * segment_size.x + graph_size_x * x_padding
	x_axis_line.position.x = (graph_size_x * segment_size.x + graph_size_x * x_padding + 0.3) / 2
	x_axis_head.position.x = (graph_size_x * segment_size.x + graph_size_x * x_padding + 0.4) / 2
	y_axis_line.mesh.size.y = graph_size_x * segment_size.y
	y_axis_line.position.y = (graph_size_x * segment_size.y + 0.2) / 2
	y_axis_head.position.y = (graph_size_x * segment_size.y + 0.3) / 2
	
	var x_axis_offset: int = 0
	for iter_item_key in value_dict:
		var iter_item_value := value_dict[iter_item_key]
		x_axis_offset += 1

		var graph_value_mesh := MeshInstance3D.new()
		graph_value_mesh.mesh = BoxMesh.new()
		graph_value_mesh.material_override = graph_material
		graph_value_mesh.mesh.size = Vector3(segment_size.x, iter_item_value, z_size)
		graph_value_mesh.position.x = x_axis_offset * segment_size.x + x_axis_offset * x_padding + 0.1 - segment_size.x / 2
		graph_value_mesh.position.y = iter_item_value / 2 + 0.1
		value_parent.add_child(graph_value_mesh)

		var graph_value_text := text_packed_scene.instantiate()
		graph_value_text.value = str(iter_item_value)
		graph_value_text.update()
		graph_value_text.position.x = graph_value_mesh.position.x - segment_size.x / 2
		graph_value_text.position.y = iter_item_value + 0.1 + 0.2
		value_parent.add_child(graph_value_text)
