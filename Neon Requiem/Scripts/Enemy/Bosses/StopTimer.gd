extends Timer

# Stop timer before delete
func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		stop()
