extends CanvasLayer

# DEPRICATED
# WAS USED TO viSUALISE THE NODES BUT TOO SLOW AND LAGGY

@onready var graph = $GraphEdit
var layer_frames = []
var neuron_nodes = []
var label_nodes = []

func drawAi(p_brain):
	return
	for child in layer_frames:
		child.queue_free()
	layer_frames.clear()
	for child in neuron_nodes:
		child.queue_free()
	neuron_nodes.clear()
	for child in label_nodes:
		child.queue_free()
	label_nodes.clear()
	for iter in range(p_brain.size() + 1):
		if iter == 0:
			var temp_input_graph = GraphNode.new()
			temp_input_graph.title = str(iter) + " INPUTS"
			temp_input_graph.position_offset = Vector2(0, 0)
			graph.add_child(temp_input_graph)
			layer_frames.append(temp_input_graph)

			for input in range(51):
				var temp_neuron_node = Button.new()
				temp_neuron_node.text = "Input: " + str(input)
				temp_input_graph.add_child(temp_neuron_node)
				label_nodes.append(temp_neuron_node)
				temp_neuron_node.pressed.connect(func(): visualise(iter, input))

				temp_input_graph.set_slot(input, false, 0, Color(1, 1, 1, 1), true, 0, Color(1, 1, 1, 1))
			continue
		
		if iter == p_brain.size():
			var iter_layer = p_brain[iter - 1]

			var temp_graph = GraphNode.new()
			temp_graph.title = "OUTPUT"
			temp_graph.position_offset = Vector2(iter * 400, 0)
			graph.add_child(temp_graph)
			layer_frames.append(temp_graph)

			for iter_neuron in range(iter_layer.size()):
				var neuron = iter_layer[iter_neuron]

				var temp_neuron_node = Button.new()
				temp_neuron_node.text = str(neuron[1])
				temp_graph.add_child(temp_neuron_node)
				neuron_nodes.append(temp_neuron_node)
				temp_neuron_node.pressed.connect(func(): visualise(iter, iter_neuron))

				temp_graph.set_slot(iter_neuron, true, 0, Color(1, 1, 1, 1), false, 0, Color(1, 1, 1, 1))
			continue

		var iter_layer = p_brain[iter - 1]

		var temp_graph = GraphNode.new()
		temp_graph.title = str(iter) + " LAYER"
		temp_graph.position_offset = Vector2(iter * 400, 0)
		graph.add_child(temp_graph)
		layer_frames.append(temp_graph)

		for iter_neuron in range(iter_layer.size()):
			var neuron = iter_layer[iter_neuron]

			var temp_neuron_node = Button.new()
			temp_neuron_node.text = str(neuron[1])
			temp_graph.add_child(temp_neuron_node)
			neuron_nodes.append(temp_neuron_node)
			
			temp_graph.set_slot(iter_neuron, true, 0, Color(1, 1, 1, 1), true, 0, Color(1, 1, 1, 1))
			temp_neuron_node.pressed.connect(func(): visualise(iter, iter_neuron))
			# graph.connect_node(layer_frames[iter - 1].name, iter_neuron, temp_graph.name, iter_neuron)
			# Enable this if ya want to nuke your pc :))
			# for iter_weight in range(neuron[0].size()):
			# 	var weight = neuron[0][iter_weight]
			# 	graph.connect_node(layer_frames[iter - 1].name, iter_weight, temp_graph.name, iter_neuron)

func visualise(p_this, this_count):
	graph.clear_connections()
	var this = layer_frames[p_this]
	if p_this > 0:
		var prev = layer_frames[p_this - 1]
		if prev:
			for iter_prev in range(prev.get_child_count()):
				graph.connect_node(prev.name, iter_prev, this.name, this_count)
	if p_this < layer_frames.size() - 1:
		var next = layer_frames[p_this + 1]
		if next:
			for iter_next in range(next.get_child_count()):
				graph.connect_node(this.name, this_count, next.name, iter_next)
