extends Control
class_name CooldownTimersController

var player : Player
var cooldowns = []
var cooldownTimerScene = preload("res://Scenes/UI/CooldownTimer.tscn")


	
func _ready():
	player = get_tree().get_first_node_in_group("Player")
	if(player):
		# Cooldown
		cooldowns = player.find_children("*Cooldown", "Timer")
		for cooldown in cooldowns:
			var cooldownObj = cooldownTimerScene.instantiate()
			cooldownObj.setProgressBarValues(0, cooldown.wait_time, cooldown.wait_time)
			$CooldownContainers.add_child(cooldownObj)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	player = get_tree().get_first_node_in_group("Player")
	if(player && cooldowns.size() == 0):
		# Cooldown
		cooldowns = player.find_children("*Cooldown", "Timer") as Array[Timer]
		for cooldown in cooldowns:
			var cooldownObj  = cooldownTimerScene.instantiate()
			cooldownObj.setProgressBarValues(0, cooldown.wait_time, cooldown.wait_time)
			$CooldownContainers.add_child(cooldownObj)

	if(player && cooldowns.size()>0):
		var cooldownObjs = $CooldownContainers.get_children()

		for idx in $CooldownContainers.get_children().size():
			var currCooldown = cooldowns[idx]
			cooldownObjs[idx].setProgressBarValues(0, currCooldown.wait_time, currCooldown.wait_time)
			cooldownObjs[idx].value = currCooldown.time_left
			if(currCooldown.is_stopped()):
				cooldownObjs[idx].updateTextLabel("")
			else:
				cooldownObjs[idx].updateTextLabel("[center][b]{timeLeft}[/b][/center]".format(({"timeLeft": round(currCooldown.time_left)})))
				
			
