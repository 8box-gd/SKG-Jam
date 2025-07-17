@icon("res://icons/icon_search.svg")
extends Node3D
#WARNING: For this to work, this node MUST be above Crackhead in the heirarchy, or else
# its children won't be ready when Crackhead asks for the patrol points.

var child_array: Array[Node]
signal points_ready(me: Node3D)

func _ready() -> void:
	child_array = get_children()
	#points_ready.emit(self)
