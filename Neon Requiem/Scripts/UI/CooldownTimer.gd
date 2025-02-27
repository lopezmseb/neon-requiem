extends Control
class_name CooldownTimersController

var player : Player
var cooldowns = []
var cooldownTimerScene = preload("res://Scenes/UI/CooldownTimer.tscn")
	
	
func _ready():
	#$CooldownContainers.size = DisplayServer.window_get_size()/10
	if(player):
		# Cooldown
		cooldowns = player.find_children("*Cooldown", "CooldownComponent")
		for cooldown in cooldowns:
			var cooldownComponent = cooldown as CooldownComponent
			var cooldownObj = cooldownTimerScene.instantiate()
			cooldownObj.initialize(cooldownComponent)
			cooldownObj.player = player			
			cooldownObj.setProgressBarValues(0, cooldown.wait_time, cooldown.wait_time)
			
			$CooldownContainers.add_child(cooldownObj)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#$CooldownContainers.size = DisplayServer.window_get_size()
	if(player && cooldowns.size() == 0):
		# Cooldown
		cooldowns = player.find_children("*Cooldown")
		for cooldown in cooldowns:
			var cooldownComponent = cooldown as CooldownComponent
			var cooldownObj = cooldownTimerScene.instantiate()
			cooldownObj.cooldownComponent = cooldownComponent
			cooldownObj.player = player
			cooldownObj.setProgressBarValues(0, cooldown.wait_time, cooldown.wait_time)
			$CooldownContainers.add_child(cooldownObj)

	#if(player && cooldowns.size()>0):
	#	var cooldownObjs = $CooldownContainers.get_children()

#		for idx in $CooldownContainers.get_children().size():
#			var currCooldown = cooldowns[idx]
#			cooldownObjs[idx].setProgressBarValues(0, currCooldown.wait_time, currCooldown.wait_time)
#			cooldownObjs[idx].value = currCooldown.time_left
#			if(currCooldown.is_stopped()):
#				cooldownObjs[idx].updateTextLabel("")
#			else:
#				cooldownObjs[idx].updateTextLabel("[center][b]{timeLeft}[/b][/center]".format(({"timeLeft": round(currCooldown.time_left)})))
				
			
