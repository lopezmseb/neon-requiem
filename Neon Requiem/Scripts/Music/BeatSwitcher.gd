extends AudioStreamPlayer

@onready var beat_notifier = $"../BeatNotifier"

func _ready():
#	Sends signal every 2 beats to change colour
	beat_notifier.beats(2).connect(func(_count):
		var shader = COLORS.OFFENSIVE_SHADER if COLORS.enemyShader == COLORS.DEFENSIVE_SHADER else COLORS.DEFENSIVE_SHADER
		COLORS.enemyShader = COLORS.OFFENSIVE_SHADER if COLORS.enemyShader == COLORS.DEFENSIVE_SHADER else COLORS.DEFENSIVE_SHADER
		GlobalSignals.onColorChange.emit()
	)
		
	play()
