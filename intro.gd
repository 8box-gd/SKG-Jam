extends Control

@onready var typewriter_sound: AudioStreamPlayer2D = $Typewriter
@onready var label: Label = $Label
@onready var key_wait: Timer = $KeyWaitTime
@export var hangtime := 4.0
var typing := false
var section_number := 0
var number_of_letters := 1
var ending_early := false

# Every string needs a space after it. Can't figure out how to fix.
# Ah. So that's why it won't work. It's impossible to display the entire string with left().
# Workaround stands.
var display_me: Array[String] = [
	"Hello! ",
	"We are conducting an experiment relating to Net-Positive lives in human beings. ",
	"Seeing your interest in our organization, we believe you will be a great volunteer. ",
	"Your only instruction going in is that your time is limited, so in that time, live as Net-Positive of a life as you can. ",
	"You will figure out the rest as you go along. ",
	"Good luck! "
]

func _ready() -> void:
	# It doesn't play sound unless this is here. What the fuck?
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	await get_tree().process_frame
	start_scene()

func start_scene() -> void:
	typewriter_sound.play()
	number_of_letters = display_me[section_number].length() 
	typing = true

func _process(_delta) -> void:
	if typing and key_wait.time_left == 0.0: type_label()
	if Input.is_action_just_pressed("sneak") and not ending_early:
		ending_early = true
		end_scene()

func type_label() -> void:
	key_wait.start()
	if number_of_letters > 0:
		label.text = display_me[section_number].left(-number_of_letters)
		number_of_letters -= 1
		#print(number_of_letters)
	if number_of_letters == 0:
		typing = false
		typewriter_sound.stream_paused = true
		switch_section()
		

func switch_section() -> void:
	await get_tree().create_timer(hangtime).timeout
	section_number += 1
	if section_number > (display_me.size() - 1): 
		end_scene()
		return
	typewriter_sound.stream_paused = false
	number_of_letters = display_me[section_number].length() 
	typing = true

func end_scene() -> void:
	await FadeTransition.fade_to_black()
	get_tree().change_scene_to_file("res://main.tscn")
