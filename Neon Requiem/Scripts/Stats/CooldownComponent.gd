extends Timer

class_name CooldownComponent

signal test
@export var image: String = ""
@export var buttonCode: Array[String] = [""]
	
func changeTimerTime(new_time: float):
	wait_time = new_time

