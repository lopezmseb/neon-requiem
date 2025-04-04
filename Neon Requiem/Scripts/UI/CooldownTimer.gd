extends Control
class_name CooldownTimersController

var player : Player
var cooldowns = []
var cooldownTimerScene = preload("res://Scenes/UI/CooldownTimer.tscn")
	
	
func _ready():
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
