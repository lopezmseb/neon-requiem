extends Node

func formatFloat(value: float):
	if(abs(value - int(value)) < 0.0001):
		return str(int(value))
	else:
		return "%.1f" % value
