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
@export var mutation_chance: SpinBox
@export var mutation_amount: SpinBox
@export var spiders_batches: SpinBox
@export var spiders_per_batch: SpinBox
@export var keep_best: CheckBox
@export var auto_save_interval: SpinBox
@export_category("Rewards")
@export var ground_height: SpinBox
@export var ground_pain: SpinBox
@export var random_goal: CheckBox
@export var goal_distance: SpinBox
@export var goal_reward: SpinBox
@export var goal_distance_reward: SpinBox
@export_category("Spider")
@export var hidden_layers: SpinBox
@export var neurons_per_layer: SpinBox
@export var memory_neurons: SpinBox
@export_category("Stats")
@export var graph_show_spiders: CheckBox
@export var graph_show_time: CheckBox
@export var graph_show_max: CheckBox
@export var graph_show_avg: CheckBox
@export var graph_show_min: CheckBox
@export_category("Others")
@export var timer: Timer
#MAX 31 SPIDERS
@export var node_visualiser: Node
@export var generation_count: Label
@export_category("Graphs")
@export var graph_min_node: Node3D
@export var graph_avg_node: Node3D
@export var graph_max_node: Node3D
@export var graph_spiders: Node3D
@export var graph_time: Node3D

var intss = 0
var spiders_arr = []
var stats_arr = {
	"generation" = 1,
	
	#simulation
	"training_time" = training_time.value,
	"mutation_amount" = mutation_amount.value,
	"spiders_batches" = spiders_batches.value,
	"spiders_per_batch" = spiders_per_batch.value,
	"keep_best" = keep_best.value,
	"auto_save_interval" = keep_best.value,

	#rewards
	"ground_height" = ground_height.value,
	"ground_pain" = ground_pain.value,
	"random_goal" = random_goal.button_pressed,
	"goal_distance" = goal_distance.value,
	"goal_reward" = goal_reward.value,
	"goal_distance_reward" = goal_distance_reward.value,

	#spider
	"hidden_layers" = hidden_layers.value,
	"neurons_per_layer" = neurons_per_layer.value,
	"memory_neurons" = memory_neurons.value,
	
	"generation_statistics" = [],
	"spider_saves" = [],
}
var best_spider = []
var load_button_arr: Array[Control] = []

func _ready() -> void:
	stats_arr = {
		"generation" = 1,
		"hidden_layers" = hidden_layers.value,
		"neurons_per_layer" = neurons_per_layer.value,
		"memory_neurons" = memory_neurons.value,
		"generation_statistics" = [],
		"spider_saves" = [],
	}

	generation_count.text = "Awaiting start"
	timer.timeout.connect(trainLoop)

	start.pressed.connect(restart)
	pause_button.pressed.connect(pauseTimer)
	force_stop_button.pressed.connect(forceEnd)
	save_button.pressed.connect(saveAi)
	open_button.pressed.connect(openExplorer)
	refresh_button.pressed.connect(refreshFiles)

	graph_show_spiders.pressed.connect(graphShowSpiders)
	graph_show_time.pressed.connect(graphShowTime)
	graph_show_max.pressed.connect(graphShowMax)
	graph_show_avg.pressed.connect(graphShowAvg)
	graph_show_min.pressed.connect(graphShowMin)

	refreshFiles()
	refreshGraphs()

func graphShowSpiders(): graph_spiders.visible = graph_show_spiders.button_pressed
func graphShowTime(): graph_time.visible = graph_show_time.button_pressed
func graphShowMax(): graph_max_node.visible = graph_show_max.button_pressed
func graphShowAvg(): graph_avg_node.visible = graph_show_avg.button_pressed
func graphShowMin(): graph_min_node.visible = graph_show_min.button_pressed

func refreshGraphs():
	if stats_arr["generation_statistics"].size() == 0: return
	if graph_min_node.visible: updateGraph(graph_min_node, "min")
	if graph_avg_node.visible: updateGraph(graph_avg_node, "avg")
	if graph_max_node.visible: updateGraph(graph_max_node, "max")
	if graph_spiders.visible: updateGraph(graph_spiders, "bat")
	if graph_time.visible: updateGraph(graph_time, "sec")

func updateGraph(graph_node, value: String):
	var result: Dictionary[String, float] = {}
	for i in range(stats_arr["generation_statistics"].size()):
		if value == "bat" or value == "spd":
			result["gen " + str(i)] = stats_arr["generation_statistics"][i]["bat"] * stats_arr["generation_statistics"][i]["spd"]
		else:
			result["gen " + str(i)] = stats_arr["generation_statistics"][i][value]
	graph_node.value_dict = result
	graph_node.update()

func saveAi():
	var dirAccess = DirAccess.open(SAVE_PATH)
	if not dirAccess:
		DirAccess.make_dir_absolute(SAVE_PATH)
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
	if not directory: return
	for file_str in directory.get_files():
		if regex.search(file_str):
			var load_button = preload_load_button.instantiate()
			load_button.get_node("Button").pressed.connect(loadFile.bind(file_str))
			load_button.get_node("Label").text = file_str
			load_button_storage.add_child(load_button)
			load_button_arr.append(load_button)

func loadFile(p_path):
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
	intss = int(json_loaded_ai[0]["generation"])
	clear_spiders()
	best_spider = json_loaded_ai[1]
	loadSpiders(json_loaded_ai[1])
	refreshGraphs()
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
		"hidden_layers" = hidden_layers.value,
		"neurons_per_layer" = neurons_per_layer.value,
		"memory_neurons" = memory_neurons.value,
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
		stats_arr["generation_statistics"].append(
			{
				"min" = randomm_picker.arr_min,
				"avg" = randomm_picker.arr_avg,
				"max" = randomm_picker.arr_max,
				"mod" = randomm_picker.arr_mod,
				"sec" = training_time.value,
				"bat" = spiders_batches.value,
				"spd" = spiders_per_batch.value,
			}
		)
		refreshGraphs()

		modifySummon(randomm_picker)

func modifySummon(p_randomm_picker: WeightedRandom) -> void:
	for y in range(spiders_batches.value):
		for x in range(spiders_per_batch.value):
			if keep_best.button_pressed and x == 0:
				spawnSpider(x + 2, y, p_randomm_picker.getMax(), false)
				continue
			spawnSpider(x + 2, y, p_randomm_picker.getRandom(), true)

func summonSpiders() -> void:
	for y in range(spiders_batches.value):
		for x in range(spiders_per_batch.value):
			spawnSpider(x + 2, y, null, false)

func loadSpiders(p_brain):
	for y in range(spiders_batches.value):
		for x in range(spiders_per_batch.value):
			spawnSpider(x + 2, y, p_brain, false)

func spawnSpider(col_layer, y_indx, p_loaded_brain, p_flavoring):
	var temp_spider = preload_spider.instantiate()
	temp_spider.position = position + Vector3(0, 0, 10 * y_indx)
	var temp_node = temp_spider.get_node("Skeleton3D/PhysicalBoneSimulator3D")
	temp_node.setCollLayers(col_layer)
	if p_loaded_brain:
		temp_spider.loadBrain(p_loaded_brain)
		if p_flavoring:
			temp_spider.flavoring(mutation_chance.value, mutation_amount.value)
	else:
		temp_spider.genBrain()
	
	#spider param setup
	temp_spider.ground_height = ground_height.value
	temp_spider.ground_pain = ground_pain.value
	temp_spider.random_goal = random_goal.button_pressed
	temp_spider.goal_distance = goal_distance.value
	temp_spider.goal_reward = goal_reward.value
	temp_spider.goal_distance_reward = goal_distance_reward.value

	temp_spider.LAYER_COUNT = stats_arr["hidden_layers"]
	temp_spider.NEURONS_IN_LAYER = stats_arr["neurons_per_layer"]
	temp_spider.MEMOR_NEURON_COUNT = stats_arr["memory_neurons"]

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
	var picked_randoms = {}
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
			probablity_max += probablity
	func getMax():
		return max_index
	func getRandom():
		var probablity = randf_range(0, probablity_max)
		var random_index = -1
		for iter in range(arr_probablity.size()):
			probablity -= arr_probablity[iter] - arr_min
			if probablity <= 0:
				var temp_val = round((arr_probablity[iter] - arr_min) / probablity_max * 100)
				if picked_randoms.has(temp_val):
					picked_randoms[temp_val] += 1
				else:
					picked_randoms[temp_val] = 1
				random_index = iter
				break
		return arr_index[random_index]
