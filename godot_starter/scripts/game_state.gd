extends Node
## Autoload: settings, stats, high scores, save/load (STARTER - not yet run in Godot).

const SAVE_PATH := "user://save.json"

var settings := {"quality": 1, "volume": 0.8, "music": 0.7, "vibration": true, "subtitles": true, "reduce_scares": false, "left_handed": false}
var stats := {"keys": 0, "coins": 0, "banished": 0, "kills": 0, "escapes": 0, "max_night": 0}
var high_scores: Array = []
var tokens := 0

func _ready() -> void:
	load_game()

func save_game() -> void:
	var data := {"settings": settings, "stats": stats, "high_scores": high_scores, "tokens": tokens}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	settings.merge(parsed.get("settings", {}), true)
	stats.merge(parsed.get("stats", {}), true)
	high_scores = parsed.get("high_scores", [])
	tokens = int(parsed.get("tokens", 0))

func add_stat(key: String, amount: int = 1) -> void:
	stats[key] = int(stats.get(key, 0)) + amount

func record_run(score: int, night: int) -> void:
	high_scores.append({"score": score, "night": night})
	high_scores.sort_custom(func(a, b): return a["score"] > b["score"])
	high_scores = high_scores.slice(0, 5)
	save_game()
