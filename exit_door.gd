@icon("res://icons/icon_door.svg")
extends Node3D

func _ready() -> void:
	#open_door()
	pass

func open_door() -> void:
	var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	#NOTE: This final value will depend on how the door is oriented in the level
	tween.tween_property(self, "rotation_degrees", Vector3(0.0, -2.0, 0.0), 1.5)

func slam_shut() -> void:
	var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
	#NOTE: This final value will depend on how the door is oriented in the level
	tween.tween_property(self, "rotation_degrees", Vector3(0.0, -2.0, 0.0), 0.4)
