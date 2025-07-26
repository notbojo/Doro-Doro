extends Control
#save file
const SAVE_PATH := "user://save_data.json"



@onready var worktimer = $WorkTimer
@onready var breaktimer = $BreakTimer
@onready var time = $PomodoroDisplay/Time
@onready var pausebutton = $TimerButtons/PauseButton
@onready var startbutton = $TimerButtons/StartButton
@onready var progressbar = $PomodoroDisplay/ProgressBar
@onready var timeentry = $Settings/TimeEntry/LineEdit
@onready var breaktimeentry = $Settings/BreakEntry/LineEdit
@onready var mainlabel = $PomodoroDisplay/Label
@onready var levelbar = $Level/ProgressBar
@onready var lvllabel = $Level/Panel/lvlLabel
@onready var coinslabel = $Level/Panel/coinslabel


var coins = 0
var lvl = 1
var lvlscaling = 1
var lvlscaling2 = 1
var workstate = true
var breakstate = false
var timerstarted = false
var breakstarted = false
var default_time := 1500.0
var default_break := 600.0


# save and load
func save_game() -> void:
	var save_data = {
		"level": lvl,
		"coins": coins,
		"progress": levelbar.value,
		"max_progress": levelbar.max_value
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return  # No save file exists yet

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	var save_data = JSON.parse_string(content)
	if save_data:
		lvl = save_data.get("level", 1)
		coins = save_data.get("coins", 0)
		levelbar.value = save_data.get("progress", 0.0)
		levelbar.max_value = save_data.get("max_progress", 3800.0)

		# Update UI
		lvllabel.text = "Level: " + str(int(lvl))
		coinslabel.text = "Coins: " + str(int(coins))

		# Recalculate scaling factors if needed
		lvlscaling = lvl * 0.55
		lvlscaling2 = lvl * 0.2

func reset_save():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("Save file wiped.")
	else:
		print("No save file to delete.")


func _ready() -> void:
	load_game()
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
			progressbar.value = breaktimer.wait_time
			startbutton.text = "Start"
			breakstarted = false
			progressbar.show()


#Physics ----------------------------------------------------

func _physics_process(delta: float) -> void:
	if workstate == true and timerstarted and worktimer.paused == false:
		var total_seconds := int(worktimer.time_left)
		var minutes := total_seconds / 60
		var seconds := total_seconds % 60
		time.text = "%02d:%02d" % [minutes, seconds]
		progressbar.value = worktimer.wait_time - worktimer.time_left
		if progressbar.value_changed:
			levelbar.value += 2 * lvlscaling2 #change 2 to 0.1 or 0.2 when public testing
		if levelbar.value == levelbar.max_value:
			levelup()
	elif breakstate == true and breakstarted:
		var total_seconds := int(breaktimer.time_left)
		var minutes := total_seconds / 60
		var seconds := total_seconds % 60
		time.text = "%02d:%02d" % [minutes, seconds]
		progressbar.value = breaktimer.time_left
	if Input.is_action_just_pressed("reset"):
		reset_save()

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
	progressbar.value = breaktimer.wait_time
	var total_seconds := int(breaktimer.wait_time)
	time.text = "%02d:%02d" % [total_seconds / 60, total_seconds % 60]
	breakstarted = false

func levelup():
	levelbar.value = 0
	lvl += 1
	coins += 50
	lvlscaling = lvl * 0.55
	lvlscaling2 = lvl * 0.2
	levelbar.max_value *= lvlscaling
	print("Level up! New level:" + str(lvl)) 
	print("New max value:" + str(levelbar.max_value))
	lvllabel.text = ("Level: " + str(lvl))
	coinslabel.text = ("Coins: " + str(coins))
	save_game()
