extends ProgressBar
class_name CooldownTimerUI

var cooldownComponent: CooldownComponent
var player : Player

func initialize(cdComponent: CooldownComponent):
	cooldownComponent = cdComponent

func setProgressBarValues(min, max, current):
	min_value = min
	max_value = max
	value = current

func updateTextLabel(newText: String):
	$Time.text = newText
	
func _ready():
	setProgressBarValues(0,1,1)
	
func _process(delta):
	if(cooldownComponent):
		$KeyCode.text = "[right]{keyCode}".format({"keyCode":cooldownComponent.buttonCode[0 if player.playerController == -1 else 1]})
		setProgressBarValues(0, cooldownComponent.wait_time, cooldownComponent.wait_time)
		value = cooldownComponent.time_left
		if(cooldownComponent.is_stopped()):
			$Time.text = ""
		else:
			$Time.text = "[center][b]{timeLeft}[/b][/center]".format(({"timeLeft": round(cooldownComponent.time_left)}))
		
	
func updateValues(min,max,current):
	setProgressBarValues(min,max,current)
