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
