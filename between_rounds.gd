extends Control

@onready var cultist_label: Label = $CultistLabel
@onready var journalist_label: Label = $JournalistLabel
@onready var key_wait: Timer = $KeyWaitTime
@export var hangtime := 4.0
@onready var tip_label: Label = $TipLabel
@onready var typewriter_sound: AudioStreamPlayer2D = $Typewriter

var section_number := 0
var number_of_letters := 1
var active_label: Label
var typing := false
var run_index := 0
var ending_early := false

var display_me: Array[String] = [
	"Hello,
	My name is Sofia Torricelli. I am a journalist representing the New York Minute. We are running a story on professional ethicists, and how they live and work.
	
	[Click to continue] ",
	"NYEC BOARD OF DIRECTORS
	INTERNAL MEMO
	
	A recent discovery in the less-than-public sciences has piqued our interest. ",
	"I would like to interview you or a representative of the New York Ethicist Collective about you and your organization’s day-to-day activities. Along with more general ethics-related questions, I would also like to discuss your organization’s central pillar of “Net-Positivity.” ",
	"In layman’s terms, it appears to be a way to not necessarily circumvent death, but to see another version of yourself die, then gain the knowledge and experience of said death without dying. It can then be done again for the next death, thus compounding. ",
	"Making every living being experience a net-positive life, while a noble goal, seems like quite the lofty task, so we want to shed some light on how you plan to do this. You don’t have to answer the question right now, but we would appreciate it if you came prepared to talk on this topic. ",
	"Because acquiring this info does not appear to have a net-negative cost for the version of the self currently alive (which we can say with certainty is real, unlike the aforementioned alternate version), and because it may result in preventing future deaths, I believe this method will greatly improve the net-positivity of the lives of humanity. ",
	"If you are interested, please reach out to me with any questions or concerns, as well as dates and times you are available to meet in person for an interview.
	Thank you,
	Sofia Torricelli
	Junior Academic Journalist, The New York Minute ",
	"Imagine a world without ignorance, without suffering, without death. What was once a wild dream may now be within reach. The dream of every living being in the universe living a Net-Positive life.
	A board meeting has been scheduled during your usual lunch breaks, in which we will discuss further research. We need to work dynamically to brainstorm a solution ASAP. You may attend virtually if necessary. ",
	"[Click to continue] "
]

var tip_texts: Array[String] = [
	"TIP: Your life time is limited. If you hear a heartbeat, better hurry up. ",
	"TIP: You will remember certain things from past lives. ",
	"TIP: If you can hear it whispering, it can hear your footsteps. ",
	"TIP: When sneaking, it can’t hear you. Don’t get too close though. ",
	"TIP: Pay attention to the lights. They show you where you’ve already been. ",
	"TIP: The digits alone aren't enough to escape. Where could you use them? ",
]

func _ready() -> void:
	#print(display_me.size())
	FadeTransition.fade_from_black(2.0)
	run_index = Carryovers.run_counter - 1
	if run_index > 8: run_index = 8
	#prints(Carryovers.run_counter - 1, run_index)
	
	if run_index <= (tip_texts.size() - 1):
		tip_label.text = tip_texts[run_index]
	else: 
		tip_label.text = " "
	
	if Carryovers.run_counter % 2 == 0:
		active_label = cultist_label
	else:
		active_label = journalist_label
	
	number_of_letters = display_me[run_index].length() 
	typing = true
	typewriter_sound.play()

func _process(_delta) -> void:
	if typing: type_label()
	if Input.is_action_just_pressed("sneak") and not ending_early: #and number_of_letters <= 0:
		ending_early = true
		go_to_game()

func type_label() -> void:
	if number_of_letters > 0:
		active_label.text = display_me[run_index].left(-number_of_letters)
		number_of_letters -= 1
		#print(number_of_letters)
	if number_of_letters == 0:
		typing = false
		typewriter_sound.stream_paused = true
		


func go_to_game() -> void:
	await FadeTransition.fade_to_black()
	get_tree().change_scene_to_file("res://main.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
