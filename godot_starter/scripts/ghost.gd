extends CharacterBody3D
## Ghost with several behaviours (STARTER - simple chase, no navmesh yet).
## For real levels: bake a NavigationRegion3D and use NavigationAgent3D.target_position.

enum Kind { GHOST, STALKER, BANSHEE, BRUTE, BLINKER }

@export var kind: Kind = Kind.GHOST
@export var base_speed := 1.85

const SPEED_MULT := {Kind.GHOST: 1.0, Kind.STALKER: 1.9, Kind.BANSHEE: 0.6, Kind.BRUTE: 0.75, Kind.BLINKER: 1.1}
const HP := {Kind.GHOST: 2, Kind.STALKER: 3, Kind.BANSHEE: 2, Kind.BRUTE: 6, Kind.BLINKER: 2}

var hp := 2
var stun := 0.0
var scream_timer := 3.0
var blink_timer := 2.5
var player: CharacterBody3D

func _ready() -> void:
	add_to_group("ghosts")
	hp = HP[kind]
	player = get_tree().get_first_node_in_group("player")
	var mesh := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.5
	capsule.height = 1.8
	mesh.mesh = capsule
	mesh.position = Vector3(0, 0.9, 0)
	add_child(mesh)
	var col := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.5
	shape.height = 1.8
	col.shape = shape
	col.position = Vector3(0, 0.9, 0)
	add_child(col)
	if kind == Kind.BRUTE:
		scale = Vector3(1.6, 1.6, 1.6)

func _physics_process(delta: float) -> void:
	if player == null:
		return
	if stun > 0.0:
		stun -= delta
		return
	var to := player.global_position - global_position
	to.y = 0.0
	var dist := to.length()
	# Shadow stalker freezes while the player looks at it.
	if kind == Kind.STALKER and player.is_looking_at(global_position + Vector3(0, 1, 0)) and dist < 30.0:
		return
	if kind == Kind.BANSHEE:
		scream_timer -= delta
		if scream_timer <= 0.0 and dist < 16.0:
			scream_timer = 7.0
			player.scream_stun(0.9)
		if dist < 6.0:
			velocity = -to.normalized() * 1.4
			move_and_slide()
			return
	if kind == Kind.BLINKER:
		blink_timer -= delta
		if blink_timer <= 0.0 and dist > 5.0 and dist < 20.0:
			blink_timer = 3.0 + randf() * 2.0
			global_position += to * 0.45
	if dist < 22.0:
		velocity = to.normalized() * base_speed * SPEED_MULT[kind] * 1.25
		move_and_slide()
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	var reach := 1.8 if kind == Kind.BRUTE else 1.2
	if dist < reach:
		player.hurt(self)

func take_flash(damage: int) -> void:
	hp -= damage
	stun = 3.2
	if hp <= 0:
		GameState.add_stat("banished")
		queue_free()
