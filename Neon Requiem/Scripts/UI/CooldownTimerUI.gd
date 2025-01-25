extends ProgressBar
class_name CooldownTimerUI

func setProgressBarValues(min, max, current):
	min_value = min
	max_value = max
	value = current
	
func _ready():
	setProgressBarValues(0,1,1)
	
func updateValues(min,max,current):
	setProgressBarValues(min,max,current)
