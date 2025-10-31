extends Camera3D

@export var enabled = true

@onready var pointer: Node3D = $Pointer

var REACH = 100
var drag_obj = null
var drag_obj_offset = Vector3.ZERO
var rotation_angle = 0
func _process(delta: float) -> void:
	if pointer.visible:
		rotation_angle += delta
		pointer.rotate_x(sin(rotation_angle) * 0.05 + 0.02)
		pointer.rotate_y(sin(rotation_angle + 1) * 0.02 + 0.05)
		pointer.rotate_z(sin(rotation_angle + 2) * 0.03 + 0.03)

		var intersection = curRaycast()

		if intersection:
			var mouse_position = get_viewport().get_mouse_position()
			var ray_point_start = project_ray_origin(mouse_position)

			pointer.scale = Vector3.ONE * sqrt((intersection['position'] - ray_point_start).length()) * 0.5
		
			if drag_obj:
				pointer.global_position = intersection['position'] + Vector3.UP * 0.3
				drag_obj.linear_velocity = (intersection['position'] + Vector3.UP * 0.3 - drag_obj.global_position + drag_obj_offset) * delta * 1000
			else:
				pointer.global_position = intersection['position']
func _input(event: InputEvent) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and enabled:
		pointer.visible = true
		
		if enabled and event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if drag_obj:
					drag_obj = null
				else:
					var intersection = curRaycast()
					if intersection and intersection['collider'].is_in_group('Movable'):
						drag_obj = intersection['collider']
						drag_obj_offset = drag_obj.global_position - intersection['position']
	else:
		if not drag_obj:
			pointer.visible = false

func curRaycast():
	var mouse_position = get_viewport().get_mouse_position()
	var ray_point_start = project_ray_origin(mouse_position)
	var ray_point_end = ray_point_start + project_ray_normal(mouse_position) * REACH

	var space_state = get_world_3d().direct_space_state

	var params = PhysicsRayQueryParameters3D.create(ray_point_start, ray_point_end)

	return space_state.intersect_ray(params)
