extends Camera3D

# Does the cursor and tool functions

enum Tool {
	VIEW,
	GRAB,
	KILL
}

@export var enabled = true
@onready var pointer: Node3D = $Pointer
@export var curent_tool := Tool.VIEW
@export var main_node: Node

var REACH = 100
var spider_selected = null
var spider_selected_offset = Vector3.ZERO
var just_selected = false
var rotation_angle = 0
var last_dist = 0
var visible_pointer = false

# Visualises pointer as well does raycasting
func _process(delta: float) -> void:
	if global.menu_open:
		pointer.visible = false
	else:
		pointer.visible = visible_pointer
	if pointer.visible:
		rotation_angle += delta
		pointer.rotate_x(sin(rotation_angle) * 0.05 * curent_tool + 0.02)
		pointer.rotate_y(sin(rotation_angle + 1) * 0.02 * curent_tool + 0.05)
		pointer.rotate_z(sin(rotation_angle + 2) * 0.03 * curent_tool + 0.03)

		var intersection = curRaycast()
		if intersection:
			var mouse_position = get_viewport().get_mouse_position()
			var ray_point_start = project_ray_origin(mouse_position)
			last_dist = ray_point_start.distance_to(intersection['position'])
			pointer.global_position = intersection['position']
		else:
			var mouse_position = get_viewport().get_mouse_position()
			var ray_point_start = project_ray_origin(mouse_position)
			pointer.global_position = ray_point_start + Vector3.UP + project_ray_normal(mouse_position) * last_dist
		
		pointerDetect(delta, intersection)

# Handles utility
func pointerDetect(delta, p_intersection):
	match curent_tool:
		Tool.VIEW:
			if spider_selected:
				if not just_selected: return
				just_selected = false
				main_node.loadPreview(spider_selected.get_parent().agent.getBrain())
			else:
				just_selected = true
		Tool.GRAB:
			if spider_selected:
				if p_intersection:
					spider_selected.linear_velocity = (p_intersection['position'] + Vector3.UP - spider_selected.global_position + spider_selected_offset) * delta * 100
				else:
					var mouse_position = get_viewport().get_mouse_position()
					var ray_point_start = project_ray_origin(mouse_position)
					spider_selected.linear_velocity = (ray_point_start + Vector3.UP + project_ray_normal(mouse_position) * last_dist - spider_selected.global_position + spider_selected_offset) * delta * 100
		Tool.KILL:
			if spider_selected:
				if main_node.canKill():
					spider_selected.get_parent().agent.queue_free()
					spider_selected = null
				else:
					spider_selected = null

# Gets clicked spider
func _input(event: InputEvent) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and enabled:
		visible_pointer = true
		# Cheecks if that is valid and spider
		if enabled and event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if spider_selected:
					spider_selected = null
				else:
					var intersection = curRaycast()
					if intersection and intersection['collider'].is_in_group('Movable'):
						spider_selected = intersection['collider']
						spider_selected_offset = spider_selected.global_position - intersection['position']
	else:
		# yeah no spider lol
		if not spider_selected:
			visible_pointer = false

# Casts rays from camera
func curRaycast():
	var mouse_position = get_viewport().get_mouse_position()
	var ray_point_start = project_ray_origin(mouse_position)
	var ray_point_end = ray_point_start + project_ray_normal(mouse_position) * REACH

	var space_state = get_world_3d().direct_space_state

	var params = PhysicsRayQueryParameters3D.create(ray_point_start, ray_point_end)

	return space_state.intersect_ray(params)
