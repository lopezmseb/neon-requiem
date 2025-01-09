extends Control
class_name CooldownTimerUI

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var dashCooldown: Timer = player.find_child("DashCooldown")

func setProgressBarValues(progressBar: ProgressBar, min, max, current):
	progressBar.min_value = min
	progressBar.max_value = max
	progressBar.value = current
	
func _ready():
	# Cooldown
	setProgressBarValues($DashCooldown, 0, dashCooldown.wait_time, dashCooldown.wait_time) 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Cooldown
	$DashCooldown.value = dashCooldown.time_left
	if(!dashCooldown.is_stopped()):
		$DashCooldown/RichTextLabel.text = "[center][b]{timeLeft}[/b][/center]".format(({"timeLeft": round(dashCooldown.time_left)}))
	else:
		$DashCooldown/RichTextLabel.text = ""
