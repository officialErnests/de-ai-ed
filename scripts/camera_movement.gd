extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

const MOUSE_SENSITIVITY = 0.5
const SPEED = 10
var distance = 3
func _input(event):
	if event.is_action_pressed("scroll_down"):
		distance += 1
	if event.is_action_pressed("scroll_up"):
		distance -= 1
	if event.is_action_pressed("r_click"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("l_click"):
		if Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		$NeckOrSmthing.rotate_x(deg_to_rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = $NeckOrSmthing.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -90, 90)
		$NeckOrSmthing.rotation_degrees = camera_rot

func _process(delta):
	var cam_xform = get_global_transform()

	var input_movement_vector = Vector2()
	var dir = Vector3()

	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1

	input_movement_vector = input_movement_vector.normalized()

	# Basis vectors are already normalized.
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x
	
	dir.y = 0
	dir = dir.normalized()
	position += dir * delta * SPEED
	$NeckOrSmthing/Dron.position = Vector3.BACK * distance
	$NeckOrSmthing/Dron.global_position.y = max($NeckOrSmthing/Dron.global_position.y, 0.1)
