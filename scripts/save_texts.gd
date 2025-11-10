extends TextEdit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	genText()

func genText():
	if text == "":
		var now_time = Time.get_datetime_dict_from_system()
		text = "TERRYS_" + str(now_time["month"]) + str(now_time["day"]) + str(now_time["hour"]) + str(now_time["minute"]) + str(now_time["second"])
	else:
		var regex := RegEx.new()
		regex.compile("([0-9|_]*$)")
		var result_text = regex.sub(text, "")
		var now_time = Time.get_datetime_dict_from_system()
		text = result_text + "_" + str(now_time["month"]) + str(now_time["day"]) + str(now_time["hour"]) + str(now_time["minute"]) + str(now_time["second"])