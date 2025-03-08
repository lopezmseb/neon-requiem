extends Timer

class_name CooldownComponent

signal test
@export var image: String = ""
@export var buttonCode: Array[String] = [""]
@onready var baseWaitTime = wait_time
	
func changeTimerTime(new_time: float):
	wait_time = new_time
	
func _process(delta):
	wait_time = clampf($CooldownAdditiveReduction.Apply(baseWaitTime), 0.1 , 10)

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		stop()
