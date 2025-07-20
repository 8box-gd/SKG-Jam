extends Node

var door_code := "111111" # Default door code should be 111111
var objectives_found := 0
var lit_torches: Array[String]
var found_objectives_list: Array[String]
var found_keypad := false
var run_counter := 0 # Increments every time the main game scene is readied

func _ready() -> void:
	door_code = roll_door_code()
	print("Door code: ", door_code)

func roll_door_code() -> String:
	return "%06d" % randi_range(0, 999999)

# WRITING DOWN FOR LATER: Idea for how Torches could work
# When you touch a torch, it lights up and adds its node name to the lit_torches array.
# When it is readied in a new scene, it checks if its name is in lit_torches, then 
# lights up if it is.
# All torches will probably necessarily have to be under the same node, to prevent
# name repeats
