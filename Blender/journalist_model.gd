extends Node3D

@onready var skeleton: Skeleton3D = %GeneralSkeleton
var meshes: Array[Node]

func _ready() -> void:
	meshes = skeleton.get_children()
	for mesh:MeshInstance3D in meshes:
		mesh.get_surface_override_material(0).emission_energy_multiplier = 1.0
