extends CanvasLayer

@onready var graph = $GraphEdit
var layer_frames = []
var vbox_nodes = []
var neuron_nodes = []
var label_nodes = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func drawAi(p_inputs):
	for child in layer_frames:
		child.queue_free()
	layer_frames.clear()
	for child in vbox_nodes:
		child.queue_free()
	vbox_nodes.clear()
	for child in neuron_nodes:
		child.queue_free()
	neuron_nodes.clear()
	for child in label_nodes:
		child.queue_free()
	label_nodes.clear()
	for iter in range(p_inputs.size() + 1):
		if iter == 0:
			var temp_input_graph = GraphFrame.new()
			temp_input_graph.title = str(iter) + " INPUTS"
			temp_input_graph.position_offset = Vector2(0, 0)
			graph.add_child(temp_input_graph)
			layer_frames.append(temp_input_graph)

			var temp_input_vbox = VBoxContainer.new()
			temp_input_graph.add_child(temp_input_vbox)
			vbox_nodes.append(temp_input_vbox)

			for neuron in range(51):
				var iter_neuron = p_inputs[iter - 1]

				var temp_input_neuron_node = GraphNode.new()
				temp_input_neuron_node.title = str(neuron) + " Input"
				temp_input_neuron_node.position_offset = Vector2(iter * 400, 0)
				temp_input_vbox.add_child(temp_input_neuron_node)
				neuron_nodes.append(temp_input_neuron_node)

				var temp_label = Label.new()
				temp_label.text = str(neuron)
				temp_input_neuron_node.add_child(temp_label)
				label_nodes.append(temp_label)
			continue
		
		if iter == p_inputs.size():
			var iter_layer = p_inputs[iter - 1]

			var temp_graph = GraphFrame.new()
			temp_graph.title = "OUTPUT"
			temp_graph.position_offset = Vector2(iter * 400, 0)
			graph.add_child(temp_graph)
			layer_frames.append(temp_graph)

			var temp_vbox = VBoxContainer.new()
			temp_graph.add_child(temp_vbox)
			vbox_nodes.append(temp_vbox)

			for neuron in range(iter_layer.size()):
				var iter_neuron = iter_layer[neuron]

				var temp_neuron_node = GraphNode.new()
				temp_neuron_node.title = str(neuron) + " Neuron"
				temp_neuron_node.position_offset = Vector2(iter * 400, 0)
				temp_vbox.add_child(temp_neuron_node)
				neuron_nodes.append(temp_neuron_node)

				var temp_label = Label.new()
				temp_label.text = str(iter_neuron[1])
				temp_neuron_node.add_child(temp_label)
				label_nodes.append(temp_label)
			continue

		var iter_layer = p_inputs[iter - 1]

		var temp_graph = GraphFrame.new()
		temp_graph.title = str(iter) + " LAYER"
		temp_graph.position_offset = Vector2(iter * 400, 0)
		graph.add_child(temp_graph)
		layer_frames.append(temp_graph)

		var temp_vbox = VBoxContainer.new()
		temp_graph.add_child(temp_vbox)
		vbox_nodes.append(temp_vbox)

		for neuron in range(iter_layer.size()):
			var iter_neuron = iter_layer[neuron]

			var temp_neuron_node = GraphNode.new()
			temp_neuron_node.title = str(neuron) + " Neuron"
			temp_neuron_node.position_offset = Vector2(iter * 400, 0)
			temp_vbox.add_child(temp_neuron_node)
			neuron_nodes.append(temp_neuron_node)

			var temp_label = Label.new()
			temp_label.text = str(iter_neuron[1])
			temp_neuron_node.add_child(temp_label)
			label_nodes.append(temp_label)
