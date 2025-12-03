class_name menu_sliding extends Button

# Handles panel opening and closing

@export var node: Control
@export var slide_offset: Vector2
@export var slide_steps: float = 1
@export var slide_speed: float = 0.01
@export var slider_open_text: String
@export var slider_close_text: String
@export var is_open = true

var is_moving = false

# Closes or open them
func _ready() -> void:
	pressed.connect(clicked)
	if not is_open: move()

# Handles click
func clicked():
	if is_moving: return
	is_moving = true

	is_open = not is_open
	global.menu_open = is_open
 	
	move()
	
	is_moving = false

# Moves panel
func move():
	for i in range(slide_steps):
		await get_tree().create_timer(slide_speed).timeout
		node.position += slide_offset / slide_steps * (-1 if is_open else 1)

	text = slider_open_text if is_open else slider_close_text
