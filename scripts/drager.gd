extends Camera3D

@export var enabled = true

@onready var pointer = $Pointer

var REACH = 100

func _input(event: InputEvent) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and enabled:
		pointer.visible = true
		# if enabled and event is InputEventMouseButton:
		var mouse_position = get_viewport().get_mouse_position()
		var ray_point_start = project_ray_origin(mouse_position)
		var ray_point_end = ray_point_start + project_ray_normal(mouse_position) * REACH

		var space_state = get_world_3d().direct_space_state

		var params = PhysicsRayQueryParameters3D.create(ray_point_start, ray_point_end)

		var intersection = space_state.intersect_ray(params)
		if intersection:
			pointer.global_position = intersection['position']
		# if event.button_index == MOUSE_BUTTON_LEFT:
	else:
		pointer.visible = false
