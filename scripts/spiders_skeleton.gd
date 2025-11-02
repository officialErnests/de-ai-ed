extends PhysicalBoneSimulator3D


# Called when the node enters the scene tree for the first time.

var bones
var base_leg_arr = []
var base_legs_left_arr = []
var base_legs_right_arr = []
var upper_legs_arr = []
var upper_legs_left_arr = []
var upper_legs_right_arr = []

func _ready() -> void:
	physical_bones_start_simulation()
	bones = get_children().filter(func(x): return x is PhysicalBone3D)
	
	for i in range(bones.size()):
		if i == 0: continue
		if i % 2 == 1:
			base_leg_arr.append(bones[i])
		else:
			upper_legs_arr.append(bones[i])
	for i in range(base_leg_arr.size()):
		if i < base_leg_arr.size() / 2.0:
			base_legs_left_arr.append(base_leg_arr[i])
		else:
			base_legs_right_arr.append(base_leg_arr[i])
	for i in range(upper_legs_arr.size()):
		if i < upper_legs_arr.size() / 2.0:
			upper_legs_left_arr.append(upper_legs_arr[i])
		else:
			upper_legs_right_arr.append(upper_legs_arr[i])

func _physics_process(delta: float) -> void:
	var s = 1

	for i in range(base_legs_left_arr.size()):
		var upper_leg = base_legs_left_arr[i]
		var basiscs = upper_leg.transform.basis
		var nb_transform = upper_leg.transform.rotated(upper_leg.transform.basis.x, PI / 2.0)
		upper_leg.angular_velocity = (nb_transform.basis.get_euler() - basiscs.get_euler()) * delta * 30 * s
	# for upper_leg in upper_legs_arr:
	# 	upper_leg.angular_velocity += upper_leg.transform.basis.get_euler(1) * delta * 20
	# for base_leg in base_legs_left_arr:
	# 	# passjoint_constraints/y/linear_limit_softness
	# 	base_leg.linear_velocity += base_leg.transform.basis.x * delta * -1
	pass
	# for base_leg in base_legs_left_arr:
	# 	base_leg.angular_velocity = base_leg.transform.basis.x * delta * -200
