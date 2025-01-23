extends Control
class_name CooldownTimerUI

var player : Player
var dashCooldown: Timer 

func setProgressBarValues(progressBar: ProgressBar, min, max, current):
	progressBar.min_value = min
	progressBar.max_value = max
	progressBar.value = current
	
func _ready():
	player = get_tree().get_first_node_in_group("Player")
	if(player):
		# Cooldown
		dashCooldown = player.find_child("DashCooldown")
		setProgressBarValues($DashCooldown, 0, dashCooldown.wait_time, dashCooldown.wait_time) 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	player = get_tree().get_first_node_in_group("Player")
	if(player):
		# Cooldown
		dashCooldown = player.find_child("DashCooldown")
		setProgressBarValues($DashCooldown, 0, dashCooldown.wait_time, dashCooldown.wait_time) 
		$DashCooldown.value = dashCooldown.time_left
		if(!dashCooldown.is_stopped()):
			$DashCooldown/RichTextLabel.text = "[center][b]{timeLeft}[/b][/center]".format(({"timeLeft": round(dashCooldown.time_left)}))
		else:
			$DashCooldown/RichTextLabel.text = ""
