extends Node3D


@export var goal: Node3D
@export var text: Label3D
@export var line: MeshInstance3D
@onready var spider_skel = $Skeleton3D/PhysicalBoneSimulator3D
@onready var spider = spider_skel.spider
var prev_range = INF


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	genGoal()
	var res = []
	for i in range(8):
		res.append(rVector3D())
		res.append(rVector3D())
	spider.setVel(res)

var timesss = 0
func _process(delta: float) -> void:
	timesss += delta
	if timesss > 1:
		timesss = 0
		var res = []
		spider.getData()
		for i in range(8):
			res.append(rVector3D())
			res.append(rVector3D())
		spider.setVel(res)
		updateVisualisation()

func rVector3D():
	return Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))

func genGoal():
	goal.global_position = spider_skel.global_position * Vector3(1, 0, 1) + Vector3(0, 1, 0) + Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized() * 5

func updateVisualisation():
	var distance = goal.global_position.distance_to(spider_skel.global_position)
	# line.material_override.albedo_color = Color(prev_range - distance, distance - prev_range, 0, 1)
	line.material_override.albedo_color = Color((prev_range - distance) * 10, (distance - prev_range) * 10, 0, 1)
	prev_range = distance
	text.text = str(round(distance * 10) / 10)
	line.scale = Vector3(1, 1, distance * 20)
	line.global_position = (goal.global_position + spider_skel.global_position) / 2
	line.look_at(spider_skel.global_position, Vector3.UP)

class Neuron_Layer:
	var neurons = []
	var output_size
	func _init(p_inputs, p_neurons, p_outputs) -> void:
		output_size = p_outputs
		for i in p_neurons:
			neurons.append(Neuron.new(p_inputs))

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
		for iter in range(p_inputs.size()):
			sum += p_inputs[iter] * weights
		sum += bias
		sum = clamp(sum, -1, 1)
		return sum