extends PanelContainer
signal completed(benefit: String)

@onready var benefitlabel = $HFlowContainer/benefitlabel
@onready var cooldown = $cooldown


func _on_check_box_pressed() -> void:
	cooldown.start()


func _on_cooldown_timeout() -> void:
	completed.emit(benefitlabel.text, self)
