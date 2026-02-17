extends Node

func _ready():
	_apply_wall_textures()

func _apply_wall_textures():
	for child in get_children():
		if child is CSGBox3D and child.name.begins_with("Wall"):
			var mat = StandardMaterial3D.new()
			mat.albedo_texture = load("res://Materials/wall_albedo.png")
			mat.normal_texture = load("res://Materials/wall_normal.png")
			mat.normal_enabled = true
			mat.roughness_texture = load("res://Materials/wall_roughness.png")
			mat.roughness_enabled = true
			mat.height_texture = load("res://Materials/wall_height.png")
			mat.height_enabled = true
			child.material_override = mat
