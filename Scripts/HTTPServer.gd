extends Node

var http_server: TCPServer
var peer: StreamPeerTCP
var pending_response: bool = false

var name_entries: Array = []
var scores: Dictionary = {}
var total_coins: int = 0

var BAR_DURATION: float = 30.0
var RAINBOW_DURATION: float = 120.0
var AUTO_SPAWN_INTERVAL: float = 10.0

var auto_spawn_timer: float = 0.0

@export var port: int = 8200
@export var api_key: String = "secret123"

func _ready():
	http_server = TCPServer.new()
	var result = http_server.listen(port)
	if result == OK:
		print("HTTP Server started on port ", port)
	else:
		push_error("Failed to start server on port " + str(port))

func _process(_delta):
	auto_spawn_timer += _delta
	if auto_spawn_timer >= AUTO_SPAWN_INTERVAL:
		auto_spawn_timer = 0.0
		_spawn_auto_coin()
	if http_server.is_connection_available() and not pending_response:
		peer = http_server.take_connection()
		pending_response = true
	
	if pending_response and peer:
		peer.poll()
		if peer.get_status() == StreamPeerTCP.STATUS_CONNECTED:
			_handle_request()
		elif peer.get_status() == StreamPeerTCP.STATUS_NONE:
			pending_response = false
	
	for entry in name_entries:
		var label: Label3D = entry[0]
		var bar: ProgressBar = entry[1]
		var coin: Node3D = entry[2]
		var time_left: float = entry[3]
		var is_rainbow: bool = entry[4]
		var hue_offset: float = entry[5]
		var bar_is_rainbow: bool = entry[7] if entry.size() > 7 else false
		
		var max_duration = RAINBOW_DURATION if bar_is_rainbow else BAR_DURATION
		
		if is_instance_valid(coin):
			label.position = coin.position + Vector3(0, 1.0, 0)
			
			if is_valid_bar(bar):
				var camera = get_viewport().get_camera_3d()
				if camera:
					var screen_pos = camera.unproject_position(coin.position + Vector3(0, 0.5, 0))
					bar.position = Vector2(screen_pos.x - 25, screen_pos.y)
				
				time_left -= _delta
				entry[3] = time_left
				bar.value = (time_left / max_duration) * 100.0
				
				if time_left <= 0:
					bar.queue_free()
					entry[1] = null
					continue
				
				if is_rainbow:
					hue_offset += _delta * 0.5
					if hue_offset > 1.0:
						hue_offset -= 1.0
					var rainbow_color = Color.from_hsv(hue_offset, 1.0, 1.0, 1.0)
					label.modulate = rainbow_color
					if bar_is_rainbow:
						bar.modulate = rainbow_color
					entry[5] = hue_offset
		else:
			if is_valid_bar(bar):
				label.queue_free()
				bar.queue_free()
				name_entries.erase(entry)
			else:
				label.queue_free()
				name_entries.erase(entry)

func is_valid_bar(bar) -> bool:
	return bar != null and is_instance_valid(bar)

func _on_coin_fell(coin_name: String):
	var active_bars = 0
	for entry in name_entries:
		if is_instance_valid(entry[2]) and is_valid_bar(entry[1]):
			active_bars += 1
	
	if active_bars > 0:
		for entry in name_entries:
			var bar_name = entry[6]
			if is_instance_valid(entry[2]) and is_valid_bar(entry[1]):
				if not scores.has(bar_name):
					scores[bar_name] = 0
				scores[bar_name] += active_bars
		total_coins += active_bars
		_update_hud()

func _update_hud():
	var hud = get_node_or_null("../Hud")
	if hud and hud.has_method("update_scores"):
		hud.update_scores(scores, total_coins)

func _handle_request():
	var bytes_available = peer.get_available_bytes()
	if bytes_available == 0:
		return
	
	var request_data = peer.get_data(bytes_available)
	if request_data[0] != OK:
		peer.disconnect_from_host()
		pending_response = false
		return
	
	var request = request_data[1].get_string_from_utf8()
	if request.is_empty():
		peer.disconnect_from_host()
		pending_response = false
		return
	
	var lines = request.split("\r\n")
	if lines.size() == 0:
		peer.disconnect_from_host()
		pending_response = false
		return
	
	var request_line = lines[0]
	var parts = request_line.split(" ")
	if parts.size() < 2:
		peer.disconnect_from_host()
		pending_response = false
		return
	
	var method = parts[0]
	var path = parts[1]
	
	if method == "GET":
		_handle_get(path)
	else:
		_send_response("405 Method Not Allowed", "Method not allowed")
		peer.disconnect_from_host()
		pending_response = false

func _handle_get(path_and_query: String):
	var path = path_and_query
	var query = ""
	
	if "?" in path:
		var split_arr = path.split("?")
		path = split_arr[0]
		query = split_arr[1]
	
	var params = _parse_query_string(query)
	
	var provided_key = params.get("key", "")
	if provided_key != api_key:
		_send_response("401 Unauthorized", "Invalid or missing key")
		peer.disconnect_from_host()
		pending_response = false
		return
	
	if params.has("name") and params["name"] != "":
		var coin_name = params["name"]
		var color = params.get("color", "")
		_spawn_named_coin(coin_name, color)
		_send_response("200 OK", "Coin spawned: " + coin_name)
	else:
		_send_response("200 OK", "Usage: /?key=" + api_key + "&name=coin_name&color=rainbow")
	
	peer.disconnect_from_host()
	pending_response = false

func _send_response(status: String, body: String):
	var response = "HTTP/1.1 " + status + "\r\n"
	response += "Content-Type: text/plain\r\n"
	response += "Content-Length: " + str(body.length()) + "\r\n"
	response += "Access-Control-Allow-Origin: *\r\n"
	response += "\r\n"
	response += body
	
	var response_bytes = response.to_utf8_buffer()
	peer.put_data(response_bytes)

func _parse_query_string(query: String) -> Dictionary:
	var params = {}
	if query.is_empty():
		return params
	
	var pairs = query.split("&")
	for pair in pairs:
		var kv = pair.split("=")
		if kv.size() == 2:
			var key = kv[0].strip_edges()
			var value = kv[1].strip_edges()
			value = _url_decode(value)
			params[key] = value
	return params

func _url_decode(text: String) -> String:
	text = text.replace("%20", " ")
	text = text.replace("%21", "!")
	text = text.replace("%22", "\"")
	text = text.replace("%23", "#")
	text = text.replace("%24", "$")
	text = text.replace("%25", "%")
	text = text.replace("%26", "&")
	text = text.replace("%27", "'")
	text = text.replace("%28", "(")
	text = text.replace("%29", ")")
	text = text.replace("%2B", "+")
	text = text.replace("%2C", ",")
	text = text.replace("%2F", "/")
	text = text.replace("%3A", ":")
	text = text.replace("%3B", ";")
	text = text.replace("%3D", "=")
	text = text.replace("%3F", "?")
	text = text.replace("%40", "@")
	text = text.replace("%5B", "[")
	text = text.replace("%5D", "]")
	text = text.replace("+", " ")
	return text

func _spawn_named_coin(coin_name: String, color: String = ""):
	var spawner = get_node_or_null("../Shooter")
	if spawner == null:
		push_error("Shooter node not found!")
		return
	
	var coin_prefab = load("res://Prefabs/coin.tscn")
	var count = 0
	for child in get_parent().get_children():
		if child.is_in_group("Del"):
			count += 1
	
	var max_coins = 200
	if count >= max_coins:
		print("Max coins reached!")
		return
	
	var coin = coin_prefab.instantiate()
	coin.name = coin_name
	coin.position = spawner.position
	get_parent().add_child(coin)
	coin.apply_central_impulse(Vector3(0, -5.0, 0))
	
	coin.delete_coin.connect(_on_coin_fell.bind(coin_name))
	
	_create_name_label(coin, coin_name, color)
	print("Spawned coin: ", coin_name)

func _spawn_auto_coin():
	var spawner = get_node_or_null("../Shooter")
	if spawner == null:
		return
	
	var coin_prefab = load("res://Prefabs/coin.tscn")
	var count = 0
	for child in get_parent().get_children():
		if child.is_in_group("Del"):
			count += 1
	
	var max_coins = 200
	if count >= max_coins:
		return
	
	var coin = coin_prefab.instantiate()
	coin.name = "AutoCoin"
	coin.position = spawner.position
	get_parent().add_child(coin)
	coin.apply_central_impulse(Vector3(0, -5.0, 0))
	
	coin.delete_coin.connect(_on_auto_coin_fell)
	print("Auto-coin spawned")

func _on_auto_coin_fell():
	var active_bars = 0
	for entry in name_entries:
		if is_instance_valid(entry[2]) and is_valid_bar(entry[1]):
			active_bars += 1
	
	if active_bars > 0:
		total_coins += active_bars
		_update_hud()

func _create_name_label(coin: Node3D, text: String, color: String = ""):
	var label = Label3D.new()
	label.name = "NameLabel"
	label.text = text
	label.font_size = 48
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = coin.position + Vector3(0, 1.0, 0)
	label.no_depth_test = true
	get_parent().add_child(label)
	
	var bar = ProgressBar.new()
	bar.name = "ScoreBar"
	bar.custom_minimum_size = Vector2(50, 10)
	bar.max_value = 100.0
	bar.value = 100.0
	bar.show_percentage = false
	
	get_parent().add_child(bar)
	
	var is_rainbow = color.to_lower() == "rainbow"
	var final_color = Color(1, 1, 1, 1)
	var bar_is_rainbow = is_rainbow
	var duration = RAINBOW_DURATION if is_rainbow else BAR_DURATION
	
	if is_rainbow:
		name_entries.append([label, bar, coin, duration, true, 0.0, text, true])
	elif color.length() == 6:
		var r = color.substr(0, 2).hex_to_int() / 255.0
		var g = color.substr(2, 2).hex_to_int() / 255.0
		var b = color.substr(4, 2).hex_to_int() / 255.0
		final_color = Color(r, g, b, 1)
		label.modulate = final_color
		bar.modulate = final_color
		name_entries.append([label, bar, coin, duration, false, 0.0, text, false])
	else:
		label.modulate = final_color
		name_entries.append([label, bar, coin, duration, false, 0.0, text, false])
