extends Label

@onready var typewriter_sound: AudioStreamPlayer2D = $Typewriter
@onready var key_wait: Timer = $KeyWaitTime
@export var hangtime := 3.0
var typing := false
var section_number := 0
var number_of_letters := 1

signal go_to_credits

var display_me: Array[String] = [
	"We hope you have learned today as much as we have learned. ",
	"You will not speak to the Press, neither your employers nor otherwise, about your experience today. ",
	"Thank you for your time and cooperation. "
]

func start_scene() -> void:
	typewriter_sound.play()
	number_of_letters = display_me[section_number].length() 
	typing = true

func _process(_delta) -> void:
	if typing and key_wait.time_left == 0.0: type_label()

func type_label() -> void:
	key_wait.start()
	if number_of_letters > 0:
		text = display_me[section_number].left(-number_of_letters)
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
	visible = false
	await FadeTransition.fade_to_black(0.4)
	go_to_credits.emit()
