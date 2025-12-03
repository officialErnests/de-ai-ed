extends Node3D

# AI AGENT 
# CONTROLLS SPIDERS NEURONS

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

# Sets up the spider and adds all the refrences needed
func _ready() -> void:
	genGoal()
	meshes_arr.append(goal)
	for iter_part in skeleton.get_children():
		if iter_part is MeshInstance3D: meshes_arr.append(iter_part)
	timesss = brain_update_interval + 1

# Checks if it is time to calculate next output, doing so on interval basis
# aka brain_update_interval
func _process(delta: float) -> void:
	timesss += delta
	# Recalcalculates brain as well checks if target is reached
	if timesss > brain_update_interval:
		timesss = 0

		# Gets target related info
		var goal_dir = [main_body.basis.x.dot(main_body.global_position.direction_to(goal.global_position))]
		# Gets body related info, aka leg angles
		goal_dir.append_array(spider.getData())

		# Calculates ai nodes as well goal
		var calculation = calculate(goal_dir)

		# Moves legs acording to output
		var upper_leg = []
		var base_leg = []
		for i in range(calculation.size() / 3.0):
			upper_leg.append(Vector3(calculation[i], 0, 0))
			base_leg.append(Vector3(calculation[i], calculation[i + 1], 0))
		spider.setVel(upper_leg, base_leg)

		updateVisualisation()

# Used for random spawn
func randomize(p_rand):
	for i: PhysicalBone3D in spider_skel.get_children():
		i.rotation = p_rand

# Defocuses from preview the spider
func setSub():
	text.layers = 1
	for mesh: MeshInstance3D in meshes_arr:
		mesh.layers = 1

# Puts spider in preview
func setMain():
	text.layers = 3
	for mesh: MeshInstance3D in meshes_arr:
		mesh.layers = 3

# Generates brain based on neurons amount and input
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

# Loads brain from passed array
func loadBrain(p_brain):
	for iter_neuron_layers in p_brain:
		neuron_layers.append(Neuron_Layer.new(null, null, iter_neuron_layers))
		
# Sets goal position
func genGoal():
	if random_goal:
		# If there is random goal enabled it takes it from set list so it is same for every spider so the wave can be evaluated eaqualy
		if random_goal_index >= random_goal_seed.size(): random_goal_index = 0
		goal.global_position = spider_skel.global_position * Vector3(1, 0, 1) + Vector3(0, 1, 0) + random_goal_seed[random_goal_index] * goal_distance
		random_goal_index += 1
	else:
		# Just puts goal infront if not random
		goal.global_position = spider_skel.global_position * Vector3(1, 0, 1) + Vector3(0, 1, 0) + Vector3(1, 0, 0).normalized() * goal_distance

# Gets how ai did on this generation
func getPoints():
	#Gets distance to next goal so it can be calculated
	var distance = goal.global_position.distance_to(spider_skel.global_position)
	points += (goal_distance - distance) * goal_distance_reward
	return points

# Gets spiders brain for saving and loading next generation
func getBrain():
	var res = []
	for iter_neuron_layer in neuron_layers:
		res.append(iter_neuron_layer.getNeuronLayer())
	return res

# Modifies brains so they get random 'flavour'
func flavoring(p_mutation_chance, p_mutation_range):
	for iter_neuron_layer in neuron_layers:
		iter_neuron_layer.flavor(p_mutation_chance, p_mutation_range)

# Updates line to goal as well if the spider is red aka too low
func updateVisualisation():
	var distance = goal.global_position.distance_to(spider_skel.global_position)
	line.material_override.albedo_color = Color((distance - prev_range) * 5, (prev_range - distance) * 5, 0, 1)
	prev_range = distance
	text.text = str(round(distance * 10) / 10)
	line.scale = Vector3(1, 1, distance * 20)
	line.global_position = (goal.global_position + spider_skel.global_position) / 2
	line.look_at(spider_skel.global_position, Vector3.UP)

# Calculates based on inputs the outputs
# TL:DR Runs brain
func calculate(p_inputs):
	# checks if spider reached goal	
	if goal.global_position.distance_to(main_body.global_position) < 1:
		genGoal()
		points += goal_reward
	# Iterates trough each neiron
	# As well memory neurons are used to rember pass calculations
	var inputs = p_inputs
	inputs.append_array(memory_neurons)
	for iter_neuron_layer in neuron_layers:
		inputs = iter_neuron_layer.calc(inputs)
	memory_neurons.clear()

	# Sets the next memory neurons
	for i in range(inputs.size() - neurons):
		memory_neurons.append(inputs[i])

	return inputs

# Neuron_layer is one hidden layer that holds multiple neurons
class Neuron_Layer:
	var neurons = []
	# On init it creates all the neurons
	func _init(p_inputs, p_neurons, p_load) -> void:
		if p_load:
			for neuron in p_load:
				neurons.append(Neuron.new(neuron[0].size()).load(neuron[0], neuron[1]))
		else:
			for i in range(p_neurons):
				neurons.append(Neuron.new(p_inputs))
				neurons[i].scramble()
	# Gets all neurons in layer, used for saving
	func getNeuronLayer():
		var res = []
		for iter_neuron in neurons:
			res.append(iter_neuron.getNeuron())
		return res
	# Adds randomnes to neurons, used for mutation
	func flavor(p_mutation_chance, p_mutation_range):
		for iter_neuron in neurons:
			iter_neuron.flavorful(p_mutation_chance, p_mutation_range)
	# Calculates layer, used for calculating next out
	func calc(p_inputs):
		var result = []
		for i in range(neurons.size()):
			result.append(neurons[i].calc(p_inputs))
		return result

# Single neuron that holds all the values as well calcultaions
class Neuron:
	var weights = []
	var bias
	var inputs_size
	# Sets how many inputs there is going to be
	func _init(p_inputs) -> void:
		inputs_size = p_inputs
	# Loads neiron weights and biases
	func load(p_weights, p_bias):
		weights = p_weights
		bias = p_bias
		return self
	# Modifies weights and bias
	func flavorful(p_mutation_chance, p_mutation_range):
		for iter_weight in weights:
			if randf_range(0, 100) < p_mutation_chance:
				iter_weight += randf_range(-p_mutation_range, p_mutation_range)
				iter_weight *= 0.99
		if randf_range(0, 100) < p_mutation_chance:
			bias += randf_range(-p_mutation_range, p_mutation_range)
			bias *= 0.99
	# Gets neuron weights and biases
	func getNeuron():
		return [weights, bias]
	# Randomizes neuron
	func scramble():
		for i in range(inputs_size):
			weights.append(randf_range(-1, 1))
		bias = randf_range(-1, 1)
	# Calculates output based on inputs
	func calc(p_inputs):
		var sum = 0
		for iter in range(inputs_size):
			sum += p_inputs[iter] * weights[iter]
		sum += bias
		sum = clamp(sum, -1, 1)
		return sum
