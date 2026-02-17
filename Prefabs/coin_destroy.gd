extends RigidBody3D

@export var Hud = load("res://Prefabs/Hud.tscn")
@export var bounds_y = -2.0
@export var bounds_x = 15.0
@export var bounds_z = 15.0

var player_name: String = "default"

signal delete_coin(coin_name: String)

func _ready():
	_apply_texture()

func _apply_texture():
	var coin_mesh = get_node_or_null("CoinMesh")
	if coin_mesh:
		var mat = StandardMaterial3D.new()
		mat.albedo_texture = load("res://Materials/coin_albedo.png")
		mat.normal_texture = load("res://Materials/coin_normal.png")
		mat.normal_enabled = true
		mat.roughness_texture = load("res://Materials/coin_roughness.png")
		mat.roughness_enabled = true
		mat.height_texture = load("res://Materials/coin_height.png")
		mat.height_enabled = true
		coin_mesh.material_override = mat

func _physics_process(_delta):
	if position.y < bounds_y or position.y > bounds_x or \
	   abs(position.x) > bounds_x or abs(position.z) > bounds_z:
		print(">>> COIN DESTROYED: ", player_name, " at position: ", position)
		_spawn_destroy_particles()
		delete_coin.emit(player_name)
		queue_free()

func _spawn_destroy_particles():
	var particles = GPUParticles3D.new()
	particles.amount = 15
	particles.lifetime = 0.4
	particles.explosiveness = 1.0
	particles.position = position
	
	var material = ParticleProcessMaterial.new()
	material.direction = Vector3(0, -1, 0)
	material.spread = 90.0
	material.initial_velocity_min = 1.0
	material.initial_velocity_max = 3.0
	material.gravity = Vector3(0, -2, 0)
	material.scale_min = 0.05
	material.scale_max = 0.15
	
	var sphere = SphereMesh.new()
	sphere.radius = 0.08
	sphere.height = 0.16
	var sphere_mat = StandardMaterial3D.new()
	sphere_mat.albedo_color = Color(0.8, 0.8, 0.8, 1)
	sphere_mat.emission_enabled = true
	sphere_mat.emission = Color(0.5, 0.5, 0.5, 1)
	sphere_mat.emission_energy_multiplier = 1.0
	sphere.material = sphere_mat
	
	particles.process_material = material
	particles.draw_pass_1 = sphere
	
	get_parent().add_child(particles)
	
	var tween = create_tween()
	tween.tween_interval(0.5)
	tween.tween_callback(particles.queue_free)
