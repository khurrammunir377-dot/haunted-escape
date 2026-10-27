extends Node3D
## Builds a tiny test arena in code so the project runs without any assets (STARTER).

const PlayerScript := preload("res://scripts/player.gd")
const GhostScript := preload("res://scripts/ghost.gd")

func _ready() -> void:
	# Floor
	var floor_body := StaticBody3D.new()
	var floor_mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(60, 60)
	floor_mesh.mesh = plane
	floor_body.add_child(floor_mesh)
	var floor_col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(60, 0.2, 60)
	floor_col.shape = box
	floor_col.position = Vector3(0, -0.1, 0)
	floor_body.add_child(floor_col)
	add_child(floor_body)
	# Light + fog (dark, moody)
	var sun := DirectionalLight3D.new()
	sun.light_energy = 0.4
	sun.rotation_degrees = Vector3(-55, 30, 0)
	add_child(sun)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.02, 0.02, 0.05)
	e.fog_enabled = true
	e.fog_density = 0.04
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.environment = e
	add_child(env)
	# Player
	var player := CharacterBody3D.new()
	player.set_script(PlayerScript)
	player.position = Vector3(0, 0.1, 8)
	add_child(player)
	# A few ghosts of each kind
	var kinds := [0, 1, 2, 3, 4]
	for i in kinds.size():
		var g := CharacterBody3D.new()
		g.set_script(GhostScript)
		g.set("kind", kinds[i])
		g.position = Vector3(-10 + i * 5, 0.1, -12)
		add_child(g)
