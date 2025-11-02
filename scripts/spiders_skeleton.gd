extends PhysicalBoneSimulator3D


# Called when the node enters the scene tree for the first time.

var bones
var base_leg_arr = []
var base_legs_left_arr = []
var base_legs_right_arr = []
var upper_legs_arr = []
var upper_legs_left_arr = []
var upper_legs_right_arr = []

var time = 0
@export var debuger: Node3D
var start_vector
var main_bone_start_inverse

func _ready() -> void:
	physical_bones_start_simulation()
	bones = get_children().filter(func(x): return x is PhysicalBone3D)
	

func _physics_process(delta: float) -> void:
	var a = 0
	var b = 0
	var s = 0
	x += 1
	if x % 10 == 0:
		print(bones[1].transform.basis.x.dot(bones[0].transform.basis.x),
		bones[1].transform.basis.y.dot(bones[0].transform.basis.y),
		bones[1].transform.basis.z.dot(bones[0].transform.basis.z))
	# debuger.basis = bones[1].transform.basis * (start_vector * (bones[0].transform.basis * bones[0].transform.basis.inverse()))
	
	for base_leg in base_leg_arr:
		base_leg.angular_velocity += base_leg.transform.basis.x * delta * 400 * a

	for base_leg in base_legs_left_arr:
		base_leg.angular_velocity += base_leg.transform.basis.y * delta * 800 * b

	for base_leg in base_legs_right_arr:
		base_leg.angular_velocity += base_leg.transform.basis.y * delta * 800 * -b

	for upper_leg in upper_legs_arr:
		upper_leg.angular_velocity += upper_leg.transform.basis.x * delta * 400 * s
	# for upper_leg in upper_legs_arr:
	# 	upper_leg.angular_velocity += upper_leg.transform.basis.get_euler(1) * delta * 20
	# for base_leg in base_legs_left_arr:
	# 	# passjoint_constraints/y/linear_limit_softness
	# 	base_leg.linear_velocity += base_leg.transform.basis.x * delta * -1
	pass
	# for base_leg in base_legs_left_arr:
	# 	base_leg.angular_velocity = base_leg.transform.basis.x * delta * -200

class Leg:
class Base_leg extends Bone:
	func _init(p_bone: PhysicalBone3D, p_uper_bone):
		super (p_bone)
		var

class Bone:
	var bone
	func _init(p_bone: PhysicalBone3D):
		bone = p_bone