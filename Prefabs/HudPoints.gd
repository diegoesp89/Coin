extends Control

@onready var score_list: RichTextLabel = $ScorePanel/ScoreList
@onready var active_list: RichTextLabel = $ActivePanel/ActiveList

func _ready():
	pass

func update_scores(scores: Dictionary):
	var text = "SCORES\n"
	text += "---------\n"
	
	var sorted_names = scores.keys()
	sorted_names.sort_custom(func(a, b): return scores[a] > scores[b])
	
	for name in sorted_names:
		text += "%s: %d\n" % [name, scores[name]]
	
	score_list.text = text

func update_active(active_info: Dictionary, multiplier: int):
	var text = "ACTIVE\n"
	text += "---------\n\n"
	
	for name in active_info:
		var time_left = active_info[name][0]
		var count = active_info[name][1]
		text += "%s: %.1fs X%d\n" % [name, time_left, count]
	
	active_list.text = text
