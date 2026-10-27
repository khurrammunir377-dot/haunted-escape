extends CharacterBody3D
## First-person controller: left half of screen = move stick, right half = look.
## Also WASD + mouse for desktop testing. Q = camera flash. (STARTER - not yet run in Godot.)

signal lives_changed(lives: int)

@export var walk_speed := 3.6
@export var run_speed := 5.6
@export var look_sens := 0.004
@export var touch_look_sens := 0.006
@export var flash_cooldown := 2.5
@export var flash_range := 14.0
@export var flash_half_angle_deg := 35.0

var lives := 3
var stamina := 1.0
var inv := 0.0
var stun := 0.0
var flash_timer := 0.0
var yaw := 0.0
var pitch := 0.0
var move_touch_id := -1
var look_touch_id := -1
var move_origin := Vector2.ZERO
var move_vec := Vector2.ZERO
var cam: Camera3D

func _ready() -> void:
	add_to_group("player")
	cam = Camera3D.new()
	cam.position = Vector3(0, 1.55, 0)
	add_child(cam)
	var shape := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.45
	cap.height = 1.7
	shape.shape = cap
	shape.position = Vector3(0, 0.85, 0)
	add_child(shape)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * look_sens
		pitch = clamp(pitch - event.relative.y * look_sens, -1.2, 1.2)
	elif event is InputEventScreenTouch:
		var half := get_viewport().get_visible_rect().size.x * 0.5
		if event.pressed:
			if event.position.x < half and move_touch_id == -1:
				move_touch_id = event.index
				move_origin = event.position
			elif event.position.x >= half and look_touch_id == -1:
				look_touch_id = event.index
		else:
			if event.index == move_touch_id:
				move_touch_id = -1
				move_vec = Vector2.ZERO
			elif event.index == look_touch_id:
				look_touch_id = -1
	elif event is InputEventScreenDrag:
		if event.index == move_touch_id:
			move_vec = ((event.position - move_origin) / 80.0).limit_length(1.0)
		elif event.index == look_touch_id:
			yaw -= event.relative.x * touch_look_sens
			pitch = clamp(pitch - event.relative.y * touch_look_sens, -1.2, 1.2)
	elif event is InputEventKey and event.pressed and event.keycode == KEY_Q:
		try_flash()
	elif event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	rotation.y = yaw
	cam.rotation.x = pitch
	inv = max(0.0, inv - delta)
	flash_timer = max(0.0, flash_timer - delta)
	var input := move_vec
	if Input.is_key_pressed(KEY_W): input.y -= 1.0
	if Input.is_key_pressed(KEY_S): input.y += 1.0
	if Input.is_key_pressed(KEY_A): input.x -= 1.0
	if Input.is_key_pressed(KEY_D): input.x += 1.0
	input = input.limit_length(1.0)
	if stun > 0.0:
		stun -= delta
		input = Vector2.ZERO
	var running := Input.is_key_pressed(KEY_SHIFT) and stamina > 0.05 and input.length() > 0.1
	var speed := run_speed if running else walk_speed
	stamina = clamp(stamina + (-0.3 if running else 0.2) * delta, 0.0, 1.0)
	var dir := transform.basis * Vector3(input.x, 0.0, input.y)
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0.0
	move_and_slide()

func try_flash() -> void:
	if flash_timer > 0.0:
		return
	flash_timer = flash_cooldown
	var forward := -global_transform.basis.z
	for g in get_tree().get_nodes_in_group("ghosts"):
		var to: Vector3 = g.global_position - global_position
		var dist := to.length()
		if dist > flash_range or dist < 0.3:
			continue
		if forward.dot(to.normalized()) < cos(deg_to_rad(flash_half_angle_deg)):
			continue
		if _has_line_of_sight(g):
			g.take_flash(1)

func _has_line_of_sight(target: Node3D) -> bool:
	var space := get_world_3d().direct_space_state
	var from := global_position + Vector3(0, 1.5, 0)
	var to := target.global_position + Vector3(0, 1.0, 0)
	var q := PhysicsRayQueryParameters3D.create(from, to)
	q.exclude = [get_rid()]
	var hit := space.intersect_ray(q)
	return hit.is_empty() or hit.get("collider") == target

func is_looking_at(point: Vector3, half_angle_deg: float = 55.0) -> bool:
	var to := (point - global_position).normalized()
	return (-global_transform.basis.z).dot(to) > cos(deg_to_rad(half_angle_deg))

func hurt(_source: Node = null) -> void:
	if inv > 0.0:
		return
	lives -= 1
	inv = 2.0
	lives_changed.emit(lives)
	if GameState.settings.get("vibration", true):
		Input.vibrate_handheld(120)
	if lives <= 0:
		GameState.record_run(0, 1)
		get_tree().reload_current_scene()

func scream_stun(seconds: float) -> void:
	stun = seconds
	stamina = max(0.0, stamina - 0.45)
