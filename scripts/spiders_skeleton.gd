extends PhysicalBoneSimulator3D


# Called when the node enters the scene tree for the first time.


var children = get_children()
var spider_armature: armature
var GRAVITY = Vector3(0, -9, 0)
func _ready() -> void:
	physical_bones_start_simulation()
	spider_armature = armature.new(get_children())

func _physics_process(delta: float) -> void:
	for x: joint in spider_armature.bones:
		pass
		# x.bone.transform.basis = x.transformation.basis
		x.bone.linear_velocity += GRAVITY * delta
		# x.bone.angular_velocity += (x.start_direction - x.bone.rotation) * delta * 1000

class armature:
	var bones = []
	func _init(p_bones) -> void:
		for iter_bone in p_bones:
			bones.append(joint.new(iter_bone))

class joint:
	var bone: PhysicalBone3D
	var transformation: Transform3D
	func _init(p_bone: PhysicalBone3D):
		bone = p_bone
		transformation = bone.transform
		print(transformation.basis.x)
