extends Control

@onready var worktimer = $WorkTimer
@onready var breaktimer = $BreakTimer
@onready var time = $PomodoroDisplay/Time
@onready var pausebutton = $TimerButtons/PauseButton
@onready var startbutton = $TimerButtons/StartButton
@onready var progressbar = $PomodoroDisplay/ProgressBar
@onready var timeentry = $Settings/TimeEntry/LineEdit
@onready var breaktimeentry = $Settings/BreakEntry/LineEdit
@onready var mainlabel = $PomodoroDisplay/Label

var workstate = true
var breakstate = false
var timerstarted = false
var breakstarted = false
var default_time := 1500.0
var default_break := 600.0

func _ready() -> void:
	workstate = true
	worktimer.wait_time = default_time
	worktimer.connect("timeout", Callable(self, "_on_work_timer_timeout"))
	breaktimer.connect("timeout", Callable(self, "_on_break_timer_timeout"))
	progressbar.hide()

func _on_start_button_pressed() -> void:
	if workstate == true:
		if not timerstarted:
			if timeentry.text == "":
				progressbar.max_value = default_time
				worktimer.wait_time = default_time
			else:
				progressbar.max_value = int(timeentry.text) * 60
				worktimer.wait_time = int(timeentry.text) * 60
			worktimer.start()
			startbutton.text = "Reset"
			timerstarted = true
			progressbar.show()
		else:
			worktimer.stop()
			if timeentry.text == "":
				worktimer.wait_time = default_time
			else:
				worktimer.wait_time = int(timeentry.text) * 60
			var total_seconds := int(worktimer.wait_time)
			time.text = "%02d:%02d" % [total_seconds / 60, total_seconds % 60]
			progressbar.value = 0
			startbutton.text = "Start"
			timerstarted = false
			progressbar.hide()
	elif breakstate == true:
		if not breakstarted:
			if breaktimeentry.text == "":
				progressbar.max_value = default_break
				breaktimer.wait_time = default_break
			else:
				progressbar.max_value = int(breaktimeentry.text) * 60
				breaktimer.wait_time = int(breaktimeentry.text) * 60
			breaktimer.start()
			breakstarted = true
			startbutton.text = "Reset"
			progressbar.show()
		else:
			breaktimer.stop()
			if breaktimeentry.text == "":
				breaktimer.wait_time = default_break
			else:
				breaktimer.wait_time = int(breaktimeentry.text) * 60
			var total_seconds := int(breaktimer.wait_time)
			time.text = "%02d:%02d" % [total_seconds / 60, total_seconds % 60]
			progressbar.value = 0
			startbutton.text = "Start"
			breakstarted = false
			progressbar.hide()

func _physics_process(delta: float) -> void:
	if workstate == true and timerstarted:
		var total_seconds := int(worktimer.time_left)
		var minutes := total_seconds / 60
		var seconds := total_seconds % 60
		time.text = "%02d:%02d" % [minutes, seconds]
		progressbar.value = worktimer.wait_time - worktimer.time_left
	elif breakstate == true and breakstarted:
		var total_seconds := int(breaktimer.time_left)
		var minutes := total_seconds / 60
		var seconds := total_seconds % 60
		time.text = "%02d:%02d" % [minutes, seconds]
		progressbar.value = breaktimer.wait_time - breaktimer.time_left

func _on_pause_button_pressed() -> void:
	if workstate == true and timerstarted:
		if not worktimer.paused:
			worktimer.paused = true
			pausebutton.text = "Resume"
		else:
			worktimer.paused = false
			pausebutton.text = "Pause"
	elif breakstate == true and breakstarted:
		if not breaktimer.paused:
			breaktimer.paused = true
			pausebutton.text = "Resume"
		else:
			breaktimer.paused = false
			pausebutton.text = "Pause"

func _on_start_button_mouse_entered() -> void:
	if (workstate and worktimer.time_left == 0):
		startbutton.text = "Good luck!"

func _on_start_button_mouse_exited() -> void:
	if (workstate and timerstarted) or (breakstate and breakstarted):
		startbutton.text = "Reset"
	else:
		startbutton.text = "Start"

func _on_work_timer_timeout() -> void:
	startbutton.text = "Start"
	timerstarted = false
	workstate = false
	breakstate = true
	breaktime()

func _on_break_timer_timeout() -> void:
	startbutton.text = "Start"
	breakstarted = false
	breakstate = false
	workstate = true
	mainlabel.text = "Pomodoro"

func breaktime():
	mainlabel.text = "Break Time :D"
	if breaktimeentry.text == "":
		breaktimer.wait_time = default_break
	else:
		breaktimer.wait_time = int(breaktimeentry.text) * 60
	progressbar.max_value = breaktimer.wait_time
	progressbar.value = 0
	var total_seconds := int(breaktimer.wait_time)
	time.text = "%02d:%02d" % [total_seconds / 60, total_seconds % 60]
	breakstarted = false
