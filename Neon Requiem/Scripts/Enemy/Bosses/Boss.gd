extends CharacterBody2D


func _physics_process(delta):
	pass


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		for i in find_children("*", "Timer"):
			var timer = i as Timer
			timer.stop()
