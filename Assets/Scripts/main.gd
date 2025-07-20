extends Control

@onready var timer = $Timer
@onready var time = $PomodoroDisplay/Time
@onready var pausebutton = $TimerButtons/PauseButton
@onready var startbutton = $TimerButtons/StartButton
@onready var progressbar = $PomodoroDisplay/ProgressBar

var timerstarted = false
var default_time := 1500.0 # 25 minutes

func _ready() -> void:
	timer.wait_time = default_time
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	progressbar.max_value = default_time
	progressbar.hide()

func _on_start_button_pressed() -> void:
	if not timerstarted:
		timer.start()
		startbutton.text = "Reset"
		timerstarted = true
		progressbar.show()
	else:
		timer.stop()
		timer.wait_time = 0
		startbutton.text = "Start"
		timerstarted = false
		progressbar.hide()

func _physics_process(delta: float) -> void:
	var total_seconds := int(timer.time_left)
	var minutes := total_seconds / 60
	var seconds := total_seconds % 60
	time.text = "%02d:%02d" % [minutes, seconds]
	progressbar.value = timer.wait_time - timer.time_left

func _on_pause_button_pressed() -> void:
	if not timer.paused:
		timer.paused = true
		pausebutton.text = "Resume"
	else:
		timer.paused = false
		pausebutton.text = "Pause"

func _on_start_button_mouse_entered() -> void:
	if timer.time_left == 0:
		startbutton.text = "Good luck!"

func _on_start_button_mouse_exited() -> void:
	if timerstarted:
		startbutton.text = "Reset"
	else:
		startbutton.text = "Start"

func _on_timer_timeout() -> void:
	startbutton.text = "Start"
	timerstarted = false
