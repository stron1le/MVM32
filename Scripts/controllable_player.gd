extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@export_range(0.0, 1.0) var mouse_sensitivity = 0.01
@export var tilt_limit = deg_to_rad(75)
@onready var _camera := $CameraYaw/CameraPivot/PlayerCam as Camera3D
@onready var _camera_pivot := $CameraYaw/CameraPivot as Node3D
@onready var _camera_yaw :=$CameraYaw as Node3D;

func _unhandled_input(event: InputEvent) -> void:
	if !_camera_pivot or !_camera_yaw:
		return;
	if event is InputEventMouseMotion:
		_camera_yaw.rotation.y -= event.relative.x * mouse_sensitivity
		# Prevent the camera from rotating too far up or down.
		_camera_pivot.rotation.x += -event.relative.y * mouse_sensitivity
		_camera_pivot.rotation.x = clampf(_camera_pivot.rotation.x, -tilt_limit, tilt_limit)
		
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (_camera_yaw.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
