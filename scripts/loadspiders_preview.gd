extends Node3D

var preload_spider = preload("res://scenes/spider.tscn")

var spider
@export var cam_holder: Node3D
var track_position = null

func _physics_process(delta: float) -> void:
	cam_holder.rotate_y(delta * 0.25)
	if track_position: cam_holder.global_position = track_position
	if spider: cam_holder.global_position = spider.get_node("Skeleton3D/PhysicalBoneSimulator3D").global_position

func spawnSpider(p_loaded_brain, stats_arr):
	var temp_spider = preload_spider.instantiate()
	temp_spider.loadBrain(p_loaded_brain)
	temp_spider.position = Vector3.ZERO

	temp_spider.ground_height = stats_arr["ground_height"]
	temp_spider.ground_pain = stats_arr["ground_pain"]
	temp_spider.random_goal = stats_arr["random_goal"]
	temp_spider.goal_distance = stats_arr["goal_distance"]
	temp_spider.goal_reward = stats_arr["goal_reward"]
	temp_spider.goal_distance_reward = stats_arr["goal_distance_reward"]

	temp_spider.LAYER_COUNT = stats_arr["hidden_layers"]
	temp_spider.NEURONS_IN_LAYER = stats_arr["neurons_per_layer"]
	temp_spider.MEMOR_NEURON_COUNT = stats_arr["memory_neurons"]

	add_child(temp_spider)
	temp_spider.get_node("Skeleton3D/PhysicalBoneSimulator3D").setCollLayers(32)
	temp_spider.setMain()
	spider = temp_spider
	
func deleteSpider():
	spider.queue_free()

func setCollLayers(p_layer):
	for iter_bone in get_children().filter(func(x): return x is PhysicalBone3D):
		iter_bone.set_collision_layer_value(1, false)
		iter_bone.set_collision_layer_value(p_layer, true)
		iter_bone.set_collision_mask_value(p_layer, true)
