class_name Player
extends CharacterBody3D

signal dug(dig_position: Vector3)
signal bag_full

@export var speed: float = 25.0
@export var mouse_sensitivity: float = 0.003
@export var dig_time: float = 1.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_digging: bool = false

@onready var head: Node3D = $Head
@onready var ray: RayCast3D = $Head/Camera3D/RayCast3D
@onready var inventory: Inventory = $Inventory

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	ray.add_exception(self)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clampf(head.rotation.x, deg_to_rad(-80.0), deg_to_rad(80.0))
	
	if event.is_action_pressed("dig") and not is_digging:
		try_dig()
		
func try_dig() -> void:
	if not ray.is_colliding():
		return
	var target := ray.get_collider() as Node
	if target == null or not target.is_in_group("diggable"):
		return
	if inventory.is_full():
		bag_full.emit()
		return
		
	var dig_position := ray.get_collision_point()
	is_digging = true
	await get_tree().create_timer(dig_time).timeout
	is_digging = false
	dug.emit(dig_position)
	

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if is_digging:
		input_dir = Vector2.ZERO
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	move_and_slide()
