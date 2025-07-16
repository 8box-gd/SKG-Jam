extends Node3D

@export var player: CharacterBody3D

signal show_keypad
signal hide_keypad

func _on_detection_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		#show_keypad.emit
		player.start_keypad()
		#print("Keypad: Show keypad")
		Carryovers.found_keypad = true
		player.update_objective()

func _on_detection_range_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		#hide_keypad.emit
		#print("Keypad: Hide keypad")
		player.leave_keypad()
