extends Node3D

var neurons: int = 52
@export_category("Neurons")
@export var NEURONS_IN_LAYER := neurons
@export var LAYER_COUNT := 1
@export var MEMOR_NEURON_COUNT := 2
@export_category("Others")
@export var goal: Node3D
@export var main_body: Node3D
@export var text: Label3D
@export var line: MeshInstance3D
@export var skeleton: Skeleton3D

@onready var spider_skel = $Skeleton3D/PhysicalBoneSimulator3D
@onready var spider = spider_skel.spider


var prev_range = INF
var points = 0
var neuron_layers = []
var memory_neurons = []
var meshes_arr = []
var timesss = 0
var random_goal_seed = []
var random_goal_index = 0

var ground_height: float
var ground_pain: float
var random_goal: bool
var goal_distance: float
var goal_reward: float
var goal_distance_reward: float
var brain_update_interval: float = 0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	genGoal()
	meshes_arr.append(goal)
	for iter_part in skeleton.get_children():
		if iter_part is MeshInstance3D: meshes_arr.append(iter_part)
	timesss = brain_update_interval + 1

func _process(delta: float) -> void:
	timesss += delta
	if timesss > brain_update_interval:
		timesss = 0
		var goal_dir = [main_body.basis.x.dot(main_body.global_position.direction_to(goal.global_position))]
		goal_dir.append_array(spider.getData())
		var calculation = calculate(goal_dir)
		var upper_leg = []
		var base_leg = []
		for i in range(calculation.size() / 3.0):
			upper_leg.append(Vector3(calculation[i], 0, 0))
			base_leg.append(Vector3(calculation[i], calculation[i + 1], 0))
		spider.setVel(upper_leg, base_leg)
		updateVisualisation()

func randomize(p_rand):
	for i: PhysicalBone3D in spider_skel.get_children():
		i.rotation = p_rand


func setSub():
	text.layers = 1
	for mesh: MeshInstance3D in meshes_arr:
		mesh.layers = 1

func setMain():
	text.layers = 3
	for mesh: MeshInstance3D in meshes_arr:
		mesh.layers = 3

func genBrain():
	if LAYER_COUNT == 1:
		neuron_layers.append(Neuron_Layer.new(neurons + MEMOR_NEURON_COUNT, NEURONS_IN_LAYER, null))
	else:
		for iter_layer in LAYER_COUNT:
			if iter_layer == 0:
				neuron_layers.append(Neuron_Layer.new(neurons, NEURONS_IN_LAYER, null))
			else:
				neuron_layers.append(Neuron_Layer.new(NEURONS_IN_LAYER, NEURONS_IN_LAYER, null))
	neuron_layers.append(Neuron_Layer.new(NEURONS_IN_LAYER, 28 + MEMOR_NEURON_COUNT, null))
	for i in range(MEMOR_NEURON_COUNT):
		memory_neurons.append(0)

func loadBrain(p_brain):
	for iter_neuron_layers in p_brain:
		neuron_layers.append(Neuron_Layer.new(null, null, iter_neuron_layers))
		
func rVector3D():
	return Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))

func genGoal():
	if random_goal:
		if random_goal_index >= random_goal_seed.size(): random_goal_index = 0
		goal.global_position = spider_skel.global_position * Vector3(1, 0, 1) + Vector3(0, 1, 0) + random_goal_seed[random_goal_index] * goal_distance
		random_goal_index += 1
	else:
		goal.global_position = spider_skel.global_position * Vector3(1, 0, 1) + Vector3(0, 1, 0) + Vector3(1, 0, 0).normalized() * goal_distance

func getPoints():
	var distance = goal.global_position.distance_to(spider_skel.global_position)
	points += (goal_distance - distance) * goal_distance_reward
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
		points += goal_reward
	var inputs = p_inputs
	inputs.append_array(memory_neurons)
	for iter_neuron_layer in neuron_layers:
		inputs = iter_neuron_layer.calc(inputs)
	memory_neurons.clear()
	for i in range(inputs.size() - neurons):
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
