extends Node3D

@export var goal := Node3D
@onready var spider_skel = $Skeleton3D/PhysicalBoneSimulator3D
@onready var spider = spider_skel.spider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
		for i in range(8):
			res.append(rVector3D())
			res.append(rVector3D())
		spider.setVel(res)


func rVector3D():
	return Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))