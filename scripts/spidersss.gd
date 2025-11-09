extends Node3D

var spider_preload = preload("res://scenes/spider.tscn")

const SAVE_PATH = "user://saves/"

@export_category("Main")
@export var start: Button
@export var pause_button: Button
@export var force_stop_button: Button
@export var save_button: Button
@export var open_button: Button
@export var load_button: Button
@export var load_file_diologue: FileDialog
@export_category("Simulation")
@export var training_time: SpinBox
@export_category("Others")
@export var timer: Timer
@export var spiders_batches = 1
#MAX 31 SPIDERS
@export var spiders_per_batch = 31
@export var keep_best = true
@export var mutation_chance = 1
@export var mutation_range = 0.1
@export var node_visualiser: Node
@export var generation_count: Label

var intss = 0
var spiders_arr = []
var stats_arr = {
	"generation" = 1,
	"generation_statistics" = []
}
var best_spider = []
func _ready() -> void:
	generation_count.text = "Awaiting start"
	timer.timeout.connect(trainLoop)

	start.pressed.connect(restart)
	pause_button.pressed.connect(pauseTimer)
	force_stop_button.pressed.connect(forceEnd)
	save_button.pressed.connect(saveAi)
	open_button.pressed.connect(openExplorer)
	load_button.pressed.connect(openExplorer)

func saveAi():
	var dirAccess = DirAccess.open("user://")
	dirAccess.make_dir(SAVE_PATH)
	var now_time = Time.get_datetime_dict_from_system()
	var file_name = SAVE_PATH + "TERRYS_" + str(now_time["month"]) + str(now_time["day"]) + str(now_time["hour"]) + str(now_time["minute"]) + str(now_time["second"]) + ".ai"

	print(file_name)
	var fileSave = FileAccess.open(file_name, FileAccess.WRITE)
	print(fileSave)
	fileSave.store_string(JSON.stringify([stats_arr, best_spider]))

func openExplorer():
	OS.execute("explorer.exe", [str(ProjectSettings.globalize_path(SAVE_PATH)).replace("/", "\\")])
	
func loadAi():
	load_file_diologue["visible"] = true
	load_file_diologue.close_requested.connect(
		func():
			load_file_diologue.visible = false
			load_file_diologue.file_selected.disconnect(loadFile)
	)
	load_file_diologue.file_selected.connect(loadFile)

func loadFile(p_path):
	print(p_path)

func pauseTimer():
	if timer.paused:
		pause_button.text = "pause"
		timer.paused = false
	else:
		pause_button.text = "resume"
		timer.paused = true


func restart():
	timer.paused = false
	start.text = "Restart training"
	startTraining()

func startTraining():
	stats_arr = {
		"generation" = 1,
		"generation_statistics" = []
	}
	timer.paused = false
	for spider in spiders_arr: spider.queue_free()
	spiders_arr.clear()
	intss = 0
	trainLoop()

func forceEnd():
	timer.stop()
	trainLoop()

func trainLoop():
	if spiders_arr.is_empty():
		summonSpiders()

	timer.start(training_time.value)
	intss += 1
	stats_arr["generation"] = intss
	generation_count.text = "Gen: " + str(intss)

	var point_arr = []
	var creature_arr = []
	for spider in spiders_arr:
		point_arr.append(spider.getPoints())
		creature_arr.append(spider.getBrain())
	var randomm_picker = WeightedRandom.new(point_arr, creature_arr)

	for spider in spiders_arr: spider.queue_free()
	spiders_arr.clear()
	node_visualiser.drawAi(randomm_picker.getMax())
	modifySummon(randomm_picker)

func modifySummon(p_randomm_picker: WeightedRandom):
	stats_arr["generation_statistics"].append(
		{
			"min" = p_randomm_picker.arr_min,
			"avg" = p_randomm_picker.arr_max,
			"max" = p_randomm_picker.arr_avg,
			"mod" = p_randomm_picker.arr_mod,
		}
	)
	for y in range(spiders_batches):
		for x in range(spiders_per_batch):
			if keep_best and x == 0:
				best_spider = p_randomm_picker.getMax()
				spawnSpider(x + 2, y, p_randomm_picker.getMax(), false)
				spiders_arr[0].setMain()
				continue
			spawnSpider(x + 2, y, p_randomm_picker.getRandom(), true)

func summonSpiders():
	for y in range(spiders_batches):
		for x in range(spiders_per_batch):
			spawnSpider(x + 2, y, null, false)

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
	var arr_max
	var arr_avg = 0
	var arr_mod
	func _init(p_probablity_arr, p_index_arr) -> void:
		arr_probablity = p_probablity_arr
		arr_index = p_index_arr
		arr_min = arr_probablity.min()
		arr_max = arr_probablity.max()
		if (arr_probablity.size() / 2) % 1 == 0:
			arr_mod = arr_probablity[arr_probablity.size() / 2.0]
		else:
			arr_mod = arr_probablity[floor(arr_probablity.size() / 2.0)] + arr_probablity[ceil(arr_probablity.size() / 2.0)]
		for iter in range(arr_probablity.size()):
			var probablity = arr_probablity[iter] - arr_min
			arr_avg += arr_probablity[iter] / arr_probablity.size()
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
