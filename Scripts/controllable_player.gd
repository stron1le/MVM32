extends CharacterBody3D


const SPEED = 5.0
const ACCEL = 10.0;
const BRAKE = 5.0;
const JUMP_VELOCITY = 6
@export_range(0,360) var gamepad_sensitivity = 180;
@export_range(0.0, 1.0) var mouse_sensitivity = 0.01
@export var tilt_limit = deg_to_rad(75)
@onready var _camera := $CameraYaw/CameraPivot/PlayerCam as Camera3D
@onready var _camera_pivot := $CameraYaw/CameraPivot as Node3D
@onready var _camera_yaw :=$CameraYaw as Node3D;
var state="Normal";
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
		if state!="LedgeGrab":
			velocity += get_gravity() * delta
	var cam_dir=Input.get_vector("ui_cam_left","ui_cam_right","ui_cam_up","ui_cam_down");
	if cam_dir:
		_camera_yaw.rotation.y -= deg_to_rad(cam_dir.x*gamepad_sensitivity*delta);
		# Prevent the camera from rotating too far up or down.
		_camera_pivot.rotation.x += deg_to_rad(cam_dir.y*gamepad_sensitivity*delta);
		_camera_pivot.rotation.x = clampf(_camera_pivot.rotation.x, -tilt_limit, tilt_limit)
	match(state):
		"Normal":
			# Handle jump.
			if Input.is_action_just_pressed("ui_accept") and is_on_floor():
				velocity.y = JUMP_VELOCITY
			# Get the input direction and handle the movement/deceleration.
			# As good practice, you should replace UI actions with custom gameplay actions.
			var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
			var target_direction = (_camera_yaw.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			if target_direction:
				var currentMovement:Vector3 = Vector3(velocity.x,0,velocity.z);
				var targetMovement=target_direction*SPEED;
				currentMovement=currentMovement.move_toward(targetMovement,ACCEL*delta);
				velocity.x=currentMovement.x;
				velocity.z=currentMovement.z;
				$EdgeChecker.look_at($EdgeChecker.global_position+target_direction.normalized());
			else:
				var currentMovement:Vector3 = Vector3(velocity.x,0,velocity.z);
				currentMovement=currentMovement.move_toward(Vector3.ZERO,BRAKE*delta);
				velocity.x=currentMovement.x;
				velocity.z=currentMovement.z;
			move_and_slide()
		"LedgeGrab":
			if Input.is_action_just_pressed("ui_accept"):
				velocity.y = JUMP_VELOCITY
				state="Normal";
			else:
				var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
				var target_direction = (_camera_yaw.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
				if (target_direction and target_direction.angle_to(-$EdgeChecker.basis.z)>deg_to_rad(150)):
					velocity.y=0;
					state="Normal";
					print("Exit");
func _on_edge_checker_edge_detected(forwardDirection):
	if !is_on_floor() and velocity.y<0:
		var savedPosition=global_position;
		var collisionInfo = move_and_collide(forwardDirection);
		if (collisionInfo):
			print(collisionInfo);
			if (collisionInfo.get_normal().y!=0):
				global_position=savedPosition;
				return;
			$EdgeChecker.look_at($EdgeChecker.global_position-collisionInfo.get_normal())
		$EdgeChecker/DownCast.force_raycast_update();
		if ($EdgeChecker/DownCast.is_colliding()):
			velocity=Vector3.ZERO;
			state="LedgeGrab";
			print("I'm on a ledge")
		else:
			global_position=savedPosition;
	pass # Replace with function body.
