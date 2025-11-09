extends Node3D

var spider_preload = preload("res://scenes/spider.tscn")

# Called when the node enters the scene tree for the first time.
@export var spiders_batches = 1
#MAX 31 SPIDERS
@export var spiders_per_batch = 31
@export var training_time = 10
@export var keep_best = true
@export var mutation_chance = 1
@export var mutation_range = 0.1
@export var node_visualiser: Node
@export var generation_count: Label
var time_left = 0

var spiders_arr = []
func _ready() -> void:
	summonSpiders()
	time_left = training_time
	generation_count.text = "Gen: " + str(intss)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_left -= delta
	if time_left < 0:
		intss += 1
		generation_count.text = "Gen: " + str(intss)
		time_left = training_time
		var point_arr = []
		var creature_arr = []
		for spider in spiders_arr:
			point_arr.append(spider.getPoints())
			creature_arr.append(spider.getBrain())
		var randomm_picker = WeightedRandom.new(point_arr, creature_arr)
		for spider in spiders_arr:
			spider.queue_free()
		spiders_arr.clear()
		print(point_arr)
		node_visualiser.drawAi(randomm_picker.getMax())
		modifySummon(randomm_picker)

func modifySummon(p_randomm_picker: WeightedRandom):
	for y in range(spiders_batches):
		for x in range(spiders_per_batch):
			if keep_best and x == 0:
				spawnSpider(x + 2, y, p_randomm_picker.getMax(), false)
				spiders_arr[0].setMain()
				continue
			spawnSpider(x + 2, y, p_randomm_picker.getRandom(), true)

func summonSpiders():
	for y in range(spiders_batches):
		for x in range(spiders_per_batch):
			spawnSpider(x + 2, y, null, false)

var intss = 0
func spawnSpider(col_layer, y_indx, p_loaded_brain, p_flavoring):
	var temp_spider = spider_preload.instantiate()
	temp_spider.position = position + Vector3(20 * y_indx, 0, 0)
	var temp_node = temp_spider.get_node("Skeleton3D/PhysicalBoneSimulator3D")
	temp_node.setCollLayers(col_layer)
	add_child(temp_spider)
	spiders_arr.append(temp_spider)
	if p_loaded_brain:
		temp_spider.loadBrain(p_loaded_brain)
		if p_flavoring:
			temp_spider.flavoring(mutation_chance, mutation_range)
	else:
		temp_spider.genBrain()

class WeightedRandom:
	var arr_probablity
	var arr_index
	var probablity_max = 0
	var max_probablity = 0
	var max_index
	var arr_min
	func _init(p_probablity_arr, p_index_arr) -> void:
		arr_probablity = p_probablity_arr
		arr_index = p_index_arr
		arr_min = arr_probablity.min()
		for iter in range(arr_probablity.size()):
			var probablity = arr_probablity[iter] - arr_min
			if max_probablity < probablity:
				max_probablity = probablity
				max_index = p_index_arr[iter]
			probablity_max += probablity - arr_min
	func getMax():
		return max_index
	func getRandom():
		var probablity = randf_range(0, probablity_max)
		var random_index = -1
		for iter in range(arr_probablity.size()):
			probablity -= arr_probablity[iter] - arr_min
			if probablity <= 0:
				random_index = iter
				break
		return arr_index[random_index]
