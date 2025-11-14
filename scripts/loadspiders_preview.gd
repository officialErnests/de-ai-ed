extends Node3D

var preload_spider = preload("res://scenes/spider.tscn")

var spider
@export var cam_holder: Node3D
var track_position = null

func _process(delta: float) -> void:
	cam_holder.rotate_y(delta * 0.25)
	if track_position: cam_holder.global_position = track_position
	if spider: cam_holder.global_position = spider.global_position

func spawnSpider(p_loaded_brain):
	var temp_spider = preload_spider.instantiate()
	temp_spider.loadBrain(p_loaded_brain)
	temp_spider.position = Vector3.ZERO
	spider = temp_spider
	temp_spider.get_node("Skeleton3D/PhysicalBoneSimulator3D").setCollLayers(31)
	temp_spider.setMain()
	add_child(temp_spider)
	
func deleteSpider():
	spider.queue_free()

func setCollLayers(p_layer):
	for iter_bone in get_children().filter(func(x): return x is PhysicalBone3D):
		iter_bone.set_collision_layer_value(1, false)
		iter_bone.set_collision_layer_value(p_layer, true)
		iter_bone.set_collision_mask_value(p_layer, true)
