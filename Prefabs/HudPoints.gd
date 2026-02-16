extends Control

@onready var score_list: RichTextLabel = $ScorePanel/ScoreList

func _ready():
	pass

func update_scores(scores: Dictionary, total: int):
	var text = "SCORES\n"
	text += "---------\n"
	
	var sorted_names = scores.keys()
	sorted_names.sort_custom(func(a, b): return scores[a] > scores[b])
	
	for name in sorted_names:
		text += "%s: %d\n" % [name, scores[name]]
	
	text += "\nTotal: %d" % total
	score_list.text = text
