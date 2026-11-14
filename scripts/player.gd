extends CharacterBody3D
## First-person desktop player. No combat, jumping, or advanced movement.
@export var walk_speed: float = 4.2
@export var look_sensitivity: float = 0.0021
var can_move: bool = true
var safe_position := Vector3(0, 1.01, 18)
@onready var eyes: Camera3D = $Camera3D

func _unhandled_input(event: InputEvent) -> void:
    if not can_move or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
        return
    if event is InputEventMouseMotion:
        rotate_y(-event.relative.x * look_sensitivity)
        eyes.rotate_x(-event.relative.y * look_sensitivity)
        eyes.rotation.x = clampf(eyes.rotation.x, -1.4, 1.4)

func _physics_process(delta: float) -> void:
    # Last zone entry is a known clear point. Also recover from future asset gaps.
    if global_position.y < -4.0:
        global_position = safe_position
        velocity = Vector3.ZERO
    if not is_on_floor():
        velocity.y -= 16.0 * delta
    else:
        velocity.y = -0.1
    var direction: Vector3 = Vector3.ZERO
    if can_move and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        var left_right: float = float(Input.is_key_pressed(KEY_D)) - float(Input.is_key_pressed(KEY_A))
        var forward_back: float = float(Input.is_key_pressed(KEY_S)) - float(Input.is_key_pressed(KEY_W))
        direction = (global_transform.basis * Vector3(left_right, 0.0, forward_back)).normalized()
        var speed: float = walk_speed * (1.35 if Input.is_key_pressed(KEY_SHIFT) else 1.0)
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
    else:
        velocity.x = 0.0
        velocity.z = 0.0
    move_and_slide()
