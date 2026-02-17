extends Control

const SCORES_FILE = "user://highscores.txt"

@onready var score_list: RichTextLabel = $ScorePanel/ScoreList
@onready var active_list: RichTextLabel = $ActivePanel/ActiveList

var scores: Dictionary = {}

func _ready():
	_load_scores()
	update_scores(scores)

func get_scores() -> Dictionary:
	return scores.duplicate()

func _load_scores():
	if FileAccess.file_exists(SCORES_FILE):
		var file = FileAccess.open(SCORES_FILE, FileAccess.READ)
		if file:
			while not file.eof_at_end():
				var line = file.get_line().strip_edges()
				if line.is_empty():
					continue
				var parts = line.split(":")
				if parts.size() == 2:
					var name = parts[0].strip_edges()
					var score = parts[1].strip_edges().to_int()
					scores[name] = score
			file.close()

func save_scores():
	var file = FileAccess.open(SCORES_FILE, FileAccess.WRITE)
	if file:
		for name in scores:
			file.store_line("%s: %d" % [name, scores[name]])
		file.close()

func update_scores(new_scores: Dictionary):
	scores = new_scores.duplicate()
	
	var text = "SCORES\n"
	text += "---------\n"
	
	var sorted_names = scores.keys()
	sorted_names.sort_custom(func(a, b): return scores[a] > scores[b])
	
	for name in sorted_names:
		text += "%s: %d\n" % [name, scores[name]]
	
	score_list.text = text
	save_scores()

func update_active(active_info: Dictionary, multiplier: int):
	var text = "ACTIVE\n"
	text += "---------\n\n"
	
	for name in active_info:
		var time_left = active_info[name][0]
		var count = active_info[name][1]
		text += "%s: %.1fs X%d\n" % [name, time_left, count]
	
	active_list.text = text
