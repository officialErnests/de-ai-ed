class_name TimeToLabel extends Label

# Shows timer

@export var timer: Timer

func _process(_delta: float) -> void:
	if not timer.paused:
		text = str(round(timer.time_left * 10) / 10)
