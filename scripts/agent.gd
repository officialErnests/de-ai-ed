extends Node3D

@export var goal := Node3D
@onready var spider_skel = $Skeleton3D/PhysicalBoneSimulator3D
@onready var spider = spider_skel.spider


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

func rVector3D():
	return Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))

func genGoal():
	goal.global_position = spider_skel.global_position * Vector3(1, 0, 1) + Vector3(0, 1, 0) + Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized() * 5
