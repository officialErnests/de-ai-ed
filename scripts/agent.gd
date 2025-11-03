extends Node3D

@export_category("Neurons")
@export var NEURONS_IN_LAYER := 51
@export var LAYER_COUNT := 1
@export_category("Others")
@export var goal: Node3D
@export var text: Label3D
@export var line: MeshInstance3D
@onready var spider_skel = $Skeleton3D/PhysicalBoneSimulator3D
@onready var spider = spider_skel.spider
var prev_range = INF
var points = 0
var neuron_layers = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	genGoal()
	var res = []
	for i in range(8):
		res.append(rVector3D())
		res.append(rVector3D())
	spider.setVel(res)

func genBrain():
	if LAYER_COUNT == 1:
		neuron_layers.append(Neuron_Layer.new(51, NEURONS_IN_LAYER))
	else:
		for iter_layer in LAYER_COUNT:
			if iter_layer == 0:
				neuron_layers.append(Neuron_Layer.new(51, NEURONS_IN_LAYER))
			else:
				neuron_layers.append(Neuron_Layer.new(NEURONS_IN_LAYER, NEURONS_IN_LAYER))
	neuron_layers.append(Neuron_Layer.new(NEURONS_IN_LAYER, 16))

func loadBrain(p_brain):
	neuron_layers = p_brain

var timesss = 0
func _process(delta: float) -> void:
	timesss += delta
	if timesss > 0.1:
		timesss = 0
		var calculation = calculate(spider.getData())
		var res = []
		for i in range(calculation.size() / 3.0):
			res.append(Vector3(calculation[i], calculation[i + 1], calculation[i + 2]))
		spider.setVel(res)
		updateVisualisation()

func rVector3D():
	return Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))

func genGoal():
	goal.global_position = spider_skel.global_position * Vector3(1, 0, 1) + Vector3(0, 1, 0) + Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized() * 5

func getPoints():
	var distance = goal.global_position.distance_to(spider_skel.global_position)
	points += max(0, 5 - distance)
	return points

func getBrain():
	return neuron_layers

func updateVisualisation():
	var distance = goal.global_position.distance_to(spider_skel.global_position)
	# line.material_override.albedo_color = Color(prev_range - distance, distance - prev_range, 0, 1)
	line.material_override.albedo_color = Color((distance - prev_range) * 5, (prev_range - distance) * 5, 0, 1)
	prev_range = distance
	text.text = str(round(distance * 10) / 10)
	line.scale = Vector3(1, 1, distance * 20)
	line.global_position = (goal.global_position + spider_skel.global_position) / 2
	line.look_at(spider_skel.global_position, Vector3.UP)

func calculate(p_inputs):
	var inputs = p_inputs
	for iter_neuron_layer in neuron_layers:
		inputs = iter_neuron_layer.calc(inputs)
	return inputs

class Neuron_Layer:
	var neurons = []
	func _init(p_inputs, p_neurons) -> void:
		for i in range(p_neurons):
			neurons.append(Neuron.new(p_inputs))
			neurons[i].scramble()

	func calc(p_inputs):
		var result = []
		for i in range(neurons.size()):
			result.append(neurons[i].calc(p_inputs))
		return result

class Neuron:
	var weights = []
	var bias
	var inputs_size
	func _init(p_inputs) -> void:
		inputs_size = p_inputs
	
	func scramble():
		for i in range(inputs_size):
			weights.append(randf_range(-1, 1))
		bias = randf_range(-1, 1)

	func calc(p_inputs):
		var sum = 0
		for iter in range(inputs_size):
			sum += p_inputs[iter] * weights[iter]
		sum += bias
		sum = clamp(sum, -1, 1)
		return sum
