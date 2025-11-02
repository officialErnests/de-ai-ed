extends PhysicalBoneSimulator3D


# Called when the node enters the scene tree for the first time.

var bones
var base_leg_arr = []
var base_legs_left_arr = []
var base_legs_right_arr = []

func _ready() -> void:
	physical_bones_start_simulation()
	bones = get_children().filter(func(x): return x is PhysicalBone3D)
	
	for i in range(bones.size()):
		if i % 2 == 1:
			base_leg_arr.append(bones[i])
	for i in range(base_leg_arr.size()):
		if i < base_leg_arr.size() / 2.0:
			base_legs_left_arr.append(base_leg_arr[i])
		else:
			base_legs_right_arr.append(base_leg_arr[i])

func _physics_process(delta: float) -> void:
	# print(bones[1].transform.basis)
	# print(bones[0].transform.basis.x)
	for base_leg in base_leg_arr:
		# print(base_leg.transform.basis.x)
		base_leg.angular_velocity = base_leg.transform.basis.x * delta * -1000
