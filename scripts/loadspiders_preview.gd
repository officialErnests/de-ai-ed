extends Node3D

# Used to load spider into preview

var preload_spider = preload("res://scenes/spider.tscn")

var spider
@export var cam_holder: Node3D
var track_position = null
signal StopLoop
var labeler: Label = null

# Rotates camera
func _process(delta: float) -> void:
	cam_holder.rotate_y(delta * 0.25)
	if track_position: cam_holder.global_position = track_position
	if spider: cam_holder.global_position += (spider.get_node("Skeleton3D/PhysicalBoneSimulator3D").global_position - cam_holder.global_position) * delta

# Starts preview slide show where the spider is loaded each interval step
func startPreview(p_stats_arr, p_time_interval) -> bool:
	StopLoop.emit()
	return await previewLoop(p_stats_arr, p_time_interval)

# Stops preview slide show
func endPreview() -> void:
	StopLoop.emit()

# Each preview slideshow loop this is called
func previewLoop(p_stats_arr, p_time_interval, p_index = 0) -> bool:
	var stopped = [false]
	StopLoop.connect(func():
		deleteSpider()
		stopped[0] = true)
	deleteSpider()
	if p_stats_arr["spider_saves"].size() > p_index:
		labeler.text = "Curently previewing: recap gen " + str(floor(p_stats_arr["spider_saves"][p_index]["gen"]))
		spawnSpider(p_stats_arr["spider_saves"][p_index]["brain"], p_stats_arr)
		await get_tree().create_timer(p_time_interval).timeout
		if stopped[0]:
			return false
		return await previewLoop(p_stats_arr, p_time_interval, p_index + 1)
	else:
		return true

# Spawns spider from brain
func spawnSpider(p_loaded_brain, stats_arr) -> void:
	var temp_spider = preload_spider.instantiate()
	temp_spider.loadBrain(p_loaded_brain)
	temp_spider.position = Vector3.ZERO

	temp_spider.ground_height = stats_arr["ground_height"]
	temp_spider.ground_pain = stats_arr["ground_pain"]
	temp_spider.random_goal = stats_arr["random_goal"]
	temp_spider.goal_distance = stats_arr["goal_distance"]
	temp_spider.goal_reward = stats_arr["goal_reward"]
	temp_spider.goal_distance_reward = stats_arr["goal_distance_reward"]
	temp_spider.brain_update_interval = stats_arr["brain_update_interval"]

	temp_spider.LAYER_COUNT = stats_arr["hidden_layers"]
	temp_spider.NEURONS_IN_LAYER = stats_arr["neurons_per_layer"]
	temp_spider.MEMOR_NEURON_COUNT = stats_arr["memory_neurons"]

	var random_goal_position = []
	for i in range(10):
		random_goal_position.append(Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized())
	temp_spider.random_goal_seed = random_goal_position
	add_child(temp_spider)
	temp_spider.get_node("Skeleton3D/PhysicalBoneSimulator3D").setCollLayers(32)
	temp_spider.setMain()
	spider = temp_spider
	
	if stats_arr["random_spawn"]:
		temp_spider.randomize(Vector3(randf_range(-PI, PI), randf_range(-PI, PI), randf_range(-PI, PI)))
	
# deletes spider
func deleteSpider():
	if spider: spider.queue_free()

# Sets collision layer of bones
func setCollLayers(p_layer):
	for iter_bone in get_children().filter(func(x): return x is PhysicalBone3D):
		iter_bone.set_collision_layer_value(1, false)
		iter_bone.set_collision_layer_value(p_layer, true)
		iter_bone.set_collision_mask_value(p_layer, true)
