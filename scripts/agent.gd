extends Node3D

@export_category("Neurons")
@export var NEURONS_IN_LAYER := 51
@export var LAYER_COUNT := 1
@export var MEMOR_NEURON_COUNT := 2
@export_category("Others")
@export var goal: Node3D
@export var main_body: Node3D
@export var text: Label3D
@export var line: MeshInstance3D
@onready var spider_skel = $Skeleton3D/PhysicalBoneSimulator3D
@onready var spider = spider_skel.spider
var prev_range = INF
var points = 0
var neuron_layers = []
var memory_neurons = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	genGoal()

func setMain():
	spider_skel.main_body.material_override.no_depth_test = true

func genBrain():
	if LAYER_COUNT == 1:
		neuron_layers.append(Neuron_Layer.new(51 + MEMOR_NEURON_COUNT, NEURONS_IN_LAYER, null))
	else:
		for iter_layer in LAYER_COUNT:
			if iter_layer == 0:
				neuron_layers.append(Neuron_Layer.new(51, NEURONS_IN_LAYER, null))
			else:
				neuron_layers.append(Neuron_Layer.new(NEURONS_IN_LAYER, NEURONS_IN_LAYER, null))
	neuron_layers.append(Neuron_Layer.new(NEURONS_IN_LAYER, 28 + MEMOR_NEURON_COUNT, null))
	for i in range(MEMOR_NEURON_COUNT):
		memory_neurons.append(0)

func loadBrain(p_brain):
	for iter_neuron_layers in p_brain:
		neuron_layers.append(Neuron_Layer.new(null, null, iter_neuron_layers))
		
var timesss = 0
func _process(delta: float) -> void:
	timesss += delta
	if timesss > 0.1:
		timesss = 0
		var calculation = calculate(spider.getData())
		var upper_leg = []
		var base_leg = []
		for i in range(calculation.size() / 3.0):
			upper_leg.append(Vector3(calculation[i], 0, 0))
			base_leg.append(Vector3(calculation[i], calculation[i + 1], 0))
		spider.setVel(upper_leg, base_leg)
		updateVisualisation()

func rVector3D():
	return Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))

func genGoal():
	goal.global_position = spider_skel.global_position * Vector3(1, 0, 1) + Vector3(0, 1, 0) + Vector3(1, 0, 0).normalized() * 5
	# goal.global_position = spider_skel.global_position * Vector3(1, 0, 1) + Vector3(0, 1, 0) + Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized() * 5

func getPoints():
	var distance = goal.global_position.distance_to(spider_skel.global_position)
	points += 5 - distance
	return points

func getBrain():
	var res = []
	for iter_neuron_layer in neuron_layers:
		res.append(iter_neuron_layer.getNeuronLayer())
	return res

func flavoring(p_mutation_chance, p_mutation_range):
	for iter_neuron_layer in neuron_layers:
		iter_neuron_layer.flavor(p_mutation_chance, p_mutation_range)

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
	if goal.global_position.distance_to(main_body.global_position) < 1:
		genGoal()
		points += 5
	var inputs = p_inputs
	inputs.append_array(memory_neurons)
	for iter_neuron_layer in neuron_layers:
		inputs = iter_neuron_layer.calc(inputs)
	memory_neurons.clear()
	for i in range(inputs.size() - 51):
		memory_neurons.append(inputs[i])
	return inputs

class Neuron_Layer:
	var neurons = []
	func _init(p_inputs, p_neurons, p_load) -> void:
		if p_load:
			for neuron in p_load:
				neurons.append(Neuron.new(neuron[0].size()).load(neuron[0], neuron[1]))
		else:
			for i in range(p_neurons):
				neurons.append(Neuron.new(p_inputs))
				neurons[i].scramble()
	func getNeuronLayer():
		var res = []
		for iter_neuron in neurons:
			res.append(iter_neuron.getNeuron())
		return res
	func flavor(p_mutation_chance, p_mutation_range):
		for iter_neuron in neurons:
			iter_neuron.flavorful(p_mutation_chance, p_mutation_range)
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
	func load(p_weights, p_bias):
		weights = p_weights
		bias = p_bias
		return self
	func flavorful(p_mutation_chance, p_mutation_range):
		for iter_weight in weights:
			if randf_range(0, 100) < p_mutation_chance:
				iter_weight += randf_range(-p_mutation_range, p_mutation_range)
				iter_weight *= 0.99
		if randf_range(0, 100) < p_mutation_chance:
			bias += randf_range(-p_mutation_range, p_mutation_range)
			bias *= 0.99
	func getNeuron():
		return [weights, bias]
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
