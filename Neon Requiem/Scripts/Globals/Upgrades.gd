extends Node

func sortArrayByPriority(a, b):
	if(not a is UpgradeStrategy and not b is UpgradeStrategy):
		return a < b
		
	return a.priority < b.priority
