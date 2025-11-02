extends PhysicalBoneSimulator3D


# Called when the node enters the scene tree for the first time.

var base_bone
var leg_base_bones = []
var leg_upper_bones = []

var time = 0
@export var debuger: Node3D
var start_vector
var main_bone_start_inverse

func _ready() -> void:
	physical_bones_start_simulation()
	var temp_bones = get_children().filter(func(x): return x is PhysicalBone3D)
	for x in range(temp_bones.size() / 2.0):
		if x == 0:
			base_bone = Leg_bone.new(
				temp_bones[x],
				null,
				null
			)
		leg_base_bones.append(Leg_bone.new(
			temp_bones[x * 2 - 1],
			base_bone.bone,
			temp_bones[x * 2]
		))
		leg_upper_bones.append(Leg_bone.new(
				temp_bones[x * 2],
				temp_bones[x * 2 - 1],
				null
		))
		leg_base_bones[x - 1].bone_next = leg_upper_bones[x - 1]

var xx = 0
func _physics_process(delta: float) -> void:
	var a = -1
	var b = 0
	var s = 1
	xx += 1
	if xx % 10 == 0:
		for iter_bone in leg_base_bones:
			pass
			print(iter_bone.getDirection())
	
	for iter_bone in leg_base_bones:
		iter_bone.addAngularVel(Vector3(
			delta * 400 * a,
			delta * 200 * b,
			0
		))

	for iter_bone in leg_upper_bones:
		iter_bone.addAngularVel(Vector3(
			delta * 400 * s,
			0,
			0
		))


class Leg_bone extends Bone:
	var bone_next
	var bone_prev
	func _init(p_bone: PhysicalBone3D, p_bone_next, p_bone_prev):
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


class Bone:
	var bone
	func _init(p_bone: PhysicalBone3D):
		bone = p_bone
