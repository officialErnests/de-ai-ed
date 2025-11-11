extends Node3D

var preload_spider = preload("res://scenes/spider.tscn")
var preload_load_button = preload("res://scenes/load_button.tscn")

const SAVE_PATH = "user://saves/"

@export_category("Main")
@export var start: Button
@export var pause_button: Button
@export var force_stop_button: Button
@export var save_button: Button
@export var save_text: TextEdit
@export var open_button: Button
@export var open_dialogue: FileDialog
@export var refresh_button: Button
@export var load_button_storage: Control
@export var save_generation: int = 50
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
	"generation_statistics" = [],
	"spider_saves" = [],
}
var best_spider = []
var load_button_arr: Array[Control] = []

func _ready() -> void:
	refreshFiles()
	generation_count.text = "Awaiting start"
	timer.timeout.connect(trainLoop)

	start.pressed.connect(restart)
	pause_button.pressed.connect(pauseTimer)
	force_stop_button.pressed.connect(forceEnd)
	save_button.pressed.connect(saveAi)
	open_button.pressed.connect(openExplorer)
	refresh_button.pressed.connect(refreshFiles)

func saveAi():
	var dirAccess = DirAccess.open("user://")
	var file_name = save_text.text
	var file_path = SAVE_PATH + file_name + ".ai"
	if FileAccess.file_exists(file_path):
		save_text.genText()
		return
	var fileSave = FileAccess.open(file_path, FileAccess.WRITE)
	if not fileSave:
		save_text.text = "ERROR - bad name"
		return
	fileSave.store_string(JSON.stringify([stats_arr, best_spider]))
	refreshFiles()

func openExplorer():
	open_dialogue.visible = true
	# OS.execute("explorer.exe", [str(ProjectSettings.globalize_path(SAVE_PATH)).replace("/", "\\")])

func refreshFiles():
	for iter_load_button in load_button_arr:
		iter_load_button.queue_free()
	load_button_arr.clear()

	var directory = DirAccess.open(SAVE_PATH)
	var regex = RegEx.new()
	regex.compile("(.ai$)")
	for file_str in directory.get_files():
		if regex.search(file_str):
			var load_button = preload_load_button.instantiate()
			load_button.get_node("Button").pressed.connect(loadFile.bind(file_str))
			load_button.get_node("Label").text = file_str
			load_button_storage.add_child(load_button)
			load_button_arr.append(load_button)

func loadFile(p_path):
	print(p_path)
	var file_loaded_ai = FileAccess.open(SAVE_PATH + p_path, FileAccess.READ)
	if not file_loaded_ai:
		save_text.text = "ERROR - failed to find"
		return
	var json_loaded_ai = JSON.parse_string(file_loaded_ai.get_line())

	if not json_loaded_ai:
		save_text.text = "ERROR - failed to load"
		return
	if not json_loaded_ai[0]:
		save_text.text = "ERROR - no data"
		return
	if not json_loaded_ai[1]:
		save_text.text = "ERROR - no spider ai"
		return

	save_text.text = p_path.substr(0, p_path.length() - 3)
	stats_arr = json_loaded_ai[0]
	intss = json_loaded_ai[0]["generation"]
	clear_spiders()
	best_spider = json_loaded_ai[1]
	loadSpiders(json_loaded_ai[1])
	startRound()

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
		"generation_statistics" = [],
		"spider_saves" = [],
	}
	timer.paused = false
	clear_spiders()
	intss = 0
	trainLoop()

func clear_spiders():
	for spider in spiders_arr: spider.queue_free()
	spiders_arr.clear()

func forceEnd():
	timer.paused = true
	trainLoop()

func startRound():
	timer.paused = false
	timer.start(training_time.value)
	generation_count.text = "Gen: " + str(intss)

func trainLoop():
	intss += 1
	startRound()

	if spiders_arr.is_empty():
		summonSpiders()

	else:
		var point_arr = []
		var creature_arr = []
		for spider in spiders_arr:
			point_arr.append(spider.getPoints())
			creature_arr.append(spider.getBrain())
		var randomm_picker = WeightedRandom.new(point_arr, creature_arr)

		clear_spiders()
		node_visualiser.drawAi(randomm_picker.getMax())

		#saving
		best_spider = randomm_picker.getMax()
		stats_arr["generation"] = intss
		if fmod(intss, save_generation) == 0:
			stats_arr["spider_saves"].append(
				{
					"gen" = intss,
					"brain" = randomm_picker.getMax()
				}
			)

		modifySummon(randomm_picker)

func modifySummon(p_randomm_picker: WeightedRandom):
	stats_arr["generation_statistics"].append(
		{
			"min" = p_randomm_picker.arr_min,
			"avg" = p_randomm_picker.arr_max,
			"max" = p_randomm_picker.arr_avg,
			"mod" = p_randomm_picker.arr_mod,
			"sec" = training_time.value,
			"bat" = spiders_batches,
			"spd" = spiders_per_batch,
		}
	)
	for y in range(spiders_batches):
		for x in range(spiders_per_batch):
			if keep_best and x == 0:
				spawnSpider(x + 2, y, p_randomm_picker.getMax(), false)
				continue
			spawnSpider(x + 2, y, p_randomm_picker.getRandom(), true)

func summonSpiders():
	for y in range(spiders_batches):
		for x in range(spiders_per_batch):
			spawnSpider(x + 2, y, null, false)

func loadSpiders(p_brain):
	for y in range(spiders_batches):
		for x in range(spiders_per_batch):
			spawnSpider(x + 2, y, p_brain, false)

func spawnSpider(col_layer, y_indx, p_loaded_brain, p_flavoring):
	var temp_spider = preload_spider.instantiate()
	temp_spider.position = position + Vector3(20 * y_indx, 0, 0)
	var temp_node = temp_spider.get_node("Skeleton3D/PhysicalBoneSimulator3D")
	temp_node.setCollLayers(col_layer)
	if p_loaded_brain:
		print("LOAD")
		temp_spider.loadBrain(p_loaded_brain)
		if p_flavoring:
			temp_spider.flavoring(mutation_chance, mutation_range)
	else:
		print("GEN")
		temp_spider.genBrain()
	add_child(temp_spider)
	if spiders_arr.is_empty():
		temp_spider.setMain()
	spiders_arr.append(temp_spider)

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
		if fmod((arr_probablity.size() / 2), 1) == 0:
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
