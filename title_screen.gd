extends Control

@onready var page_flip: AudioStreamPlayer2D = $PageFlip
var transitioning := false

func _ready() -> void:
	FadeTransition.fade_from_black()


func _on_start_button_pressed() -> void:
	if transitioning: return
	transitioning = true
	page_flip.play()
	await FadeTransition.fade_to_black()
	get_tree().change_scene_to_file("res://intro.tscn")


func _on_credits_button_pressed() -> void:
	if transitioning: return
	transitioning = true
	page_flip.play()
	await FadeTransition.fade_to_black()
	get_tree().change_scene_to_file("res://credits.tscn")
