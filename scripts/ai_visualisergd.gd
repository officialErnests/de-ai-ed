extends CanvasLayer

@onready var graph = $GraphEdit
var layer_frames = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func drawAi(p_inputs):
	for child in layer_frames:
		child.queue_free()
	layer_frames.clear()
	for iter in range(p_inputs.size()):
		var iter_layer = p_inputs[iter]

		var temp_graph = GraphFrame.new()
		temp_graph.title = str(iter) + " Layer"
		temp_graph.position_offset = Vector2(iter * 400, 0)
		graph.add_child(temp_graph)
		layer_frames.append(temp_graph)
