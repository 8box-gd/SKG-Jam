extends Control

var leaving := false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	FadeTransition.fade_from_black(0.7)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel") and not leaving:
		await FadeTransition.fade_to_black()
		get_tree().change_scene_to_file("res://title_screen.tscn")
