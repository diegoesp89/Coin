extends Node

var config: Dictionary = {}

func _ready():
	_load_env()

func _load_env():
	var env_file = ".env"
	if FileAccess.file_exists(env_file):
		var file = FileAccess.open(env_file, FileAccess.READ)
		if file:
			while not file.eof_at_end():
				var line = file.get_line().strip_edges()
				if line.is_empty() or line.begins_with("#"):
					continue
				var parts = line.split("=")
				if parts.size() == 2:
					var key = parts[0].strip_edges()
					var value = parts[1].strip_edges()
					config[key] = value
			file.close()
	
	_apply_config()

func _apply_config():
	var http_server = get_node_or_null("HTTPServer")
	if http_server:
		if config.has("HTTP_PORT"):
			http_server.set("port", config["HTTP_PORT"].to_int())
		if config.has("API_KEY"):
			http_server.set("api_key", config["API_KEY"])
		if config.has("AUTO_SPAWN_INTERVAL"):
			http_server.set("AUTO_SPAWN_INTERVAL", config["AUTO_SPAWN_INTERVAL"].to_float())
		if config.has("BAR_DURATION"):
			http_server.set("BAR_DURATION", config["BAR_DURATION"].to_float())
		if config.has("PAID_DURATION"):
			http_server.set("PAID_DURATION", config["PAID_DURATION"].to_float())
		if config.has("RAINBOW_DURATION"):
			http_server.set("RAINBOW_DURATION", config["RAINBOW_DURATION"].to_float())
		if config.has("MAX_COINS"):
			http_server.set("MAX_COINS", config["MAX_COINS"].to_int())
		if config.has("SPAWN_FORCE"):
			http_server.set("SPAWN_FORCE", config["SPAWN_FORCE"].to_float())
		if config.has("TIME_SCALE_FAST"):
			http_server.set("TIME_SCALE_FAST", config["TIME_SCALE_FAST"].to_float())
		if config.has("TIME_SCALE_FASTEST"):
			http_server.set("TIME_SCALE_FASTEST", config["TIME_SCALE_FASTEST"].to_float())
	
	var coin_spawner = get_node_or_null("Shooter")
	if coin_spawner and config.has("SPAWN_FORCE"):
		coin_spawner.set("spawn_force", config["SPAWN_FORCE"].to_float())

func get_config(key: String, default: String = "") -> String:
	return config.get(key, default)
