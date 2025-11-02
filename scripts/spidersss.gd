extends Node3D

var spider_preload = preload("res://scenes/spider.tscn")

# Called when the node enters the scene tree for the first time.
@export var spiders_batches = 1
func _ready() -> void:
	for i in range(spiders_batches):
		for x in range(31):
			var temp_spider = spider_preload.instantiate()
			temp_spider.position = position
			var temp_node = temp_spider.get_node("Skeleton3D/PhysicalBoneSimulator3D")
			temp_node.setCollLayers(x + 2)
			print(x + 2)
			add_child(temp_spider)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
