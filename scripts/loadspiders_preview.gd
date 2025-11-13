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
	temp_spider.position = Vector3.ZERO
	temp_spider.loadBrain(p_loaded_brain)
	spider = temp_spider
	
func deleteSpider():
	spider.queue_free()