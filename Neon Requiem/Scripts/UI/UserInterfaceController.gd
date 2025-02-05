extends CanvasLayer

@export var levelCount: int = 1

func _process(delta):
	if(levelCount):
		$Level.text = "Level: {level}".format({"level": levelCount})


