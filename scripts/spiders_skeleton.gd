extends PhysicalBoneSimulator3D


# Called when the node enters the scene tree for the first time.
var time = 0
var start_vector
var main_bone_start_inverse
var spider
var velocity_arr = []
@export var main_bone: PhysicalBone3D
@export var main_body: MeshInstance3D
@export var agent: Node3D
@export var pain_pos: float = 1
func _ready() -> void:
	physical_bones_start_simulation()
	spider = Spider.new(get_children().filter(func(x): return x is PhysicalBone3D), self)
	

func _physics_process(delta: float) -> void:
	spider.addVel(delta)
	if main_bone.global_position.y < pain_pos:
		agent.points += (main_bone.global_position.y - pain_pos) * delta * 2
		main_body.material_override.albedo_color = Color(1, 0, 0, 1)
	else:
		main_body.material_override.albedo_color = Color(1, 1, 1, 1)
func setCollLayers(p_layer):
	for iter_bone in get_children().filter(func(x): return x is PhysicalBone3D):
		iter_bone.set_collision_layer_value(1, false)
		iter_bone.set_collision_layer_value(p_layer, true)
		iter_bone.set_collision_mask_value(p_layer, true)

class Spider:
	var bone_base
	var bone_base_start_transform
	var leg_base_bones = []
	var leg_upper_bones = []
	var velocity_set = false
	var skeleton_main_node
	func _init(p_bones, p_main) -> void:
		skeleton_main_node = p_main
		for x in range((p_bones.size() + 1) / 2.0):
			if x == 0:
				bone_base = Leg_bone.new(p_bones[x], null, null)
				bone_base_start_transform = p_bones[x].transform
				continue
			leg_base_bones.append(Leg_bone.new(
				p_bones[x * 2 - 1],
				bone_base.bone,
				p_bones[x * 2]
			))
			leg_upper_bones.append(Leg_bone.new(
					p_bones[x * 2],
					p_bones[x * 2 - 1],
					null
			))
	
	func getData():
		skeleton_main_node.global_position = bone_base.bone.global_position
		var result = []
		var t_bone_direction = Vector3(bone_base.bone.transform.basis.x.dot(bone_base_start_transform.basis.x),
				bone_base.bone.transform.basis.y.dot(bone_base_start_transform.basis.y),
				bone_base.bone.transform.basis.z.dot(bone_base_start_transform.basis.z))
		result.append(t_bone_direction.x)
		result.append(t_bone_direction.y)
		result.append(t_bone_direction.z)
		for i_bone in leg_base_bones:
			t_bone_direction = i_bone.getDirection()
			result.append(t_bone_direction.x)
			result.append(t_bone_direction.y)
			result.append(t_bone_direction.z)
		for i_bone in leg_upper_bones:
			t_bone_direction = i_bone.getDirection()
			result.append(t_bone_direction.x)
			result.append(t_bone_direction.y)
			result.append(t_bone_direction.z)
		return result
	
	func setVel(p_upper_leg, p_base_leg):
		velocity_set = true
		for i_vel in range(leg_base_bones.size()):
			leg_base_bones[i_vel].set_dir_velocity = p_base_leg[i_vel]
			leg_upper_bones[i_vel].set_dir_velocity = p_upper_leg[i_vel]

	func addVel(delta):
		if not velocity_set: return
		for i in leg_base_bones: i.addVel(delta * 150)
		for i in leg_upper_bones: i.addVel(delta * 100)
			

class Leg_bone extends Bone:
	var bone_next
	var bone_prev
	var set_dir_velocity = Vector3.ZERO
	func _init(p_bone: PhysicalBone3D, p_bone_prev, p_bone_next):
		super (p_bone)
		if p_bone_next: bone_next = p_bone_next
		if p_bone_prev: bone_prev = p_bone_prev
	
	func getDirection():
		return Vector3(bone.transform.basis.x.dot(bone_prev.transform.basis.x),
				bone.transform.basis.y.dot(bone_prev.transform.basis.y),
				bone.transform.basis.z.dot(bone_prev.transform.basis.z))
	
	func addAngularVel(p_velocity):
		bone.angular_velocity += bone.transform.basis.x * p_velocity.x \
								+ bone.transform.basis.y * p_velocity.y \
								+ bone.transform.basis.z * p_velocity.z
	
	func addVel(delta):
		addAngularVel(set_dir_velocity * delta)

class Bone:
	var bone
	func _init(p_bone: PhysicalBone3D):
		bone = p_bone
