class_name Player_Cam extends Node3D
@onready var _camera := $CameraPivot/PlayerCam as Camera3D
@onready var _camera_pivot := $CameraPivot as Node3D
@onready var _camera_yaw := self;
@onready var cursorCast :=$CameraPivot/PlayerCam/cursorCast as RayCast3D;
@export_range(0,360) var gamepad_sensitivity = 180;
@export_range(0.0, 1.0) var mouse_sensitivity = 0.01
@export var tilt_limit = deg_to_rad(75)
@export var target:Node3D;
static var singleton:Player_Cam=null;
var canShowCursor = false;
# Called when the node enters the scene tree for the first time.
func _ready():
	singleton=self;
	if (get_parent()):
		call_deferred("reparent",get_tree().current_scene);
	pass # Replace with function body.
func _unhandled_input(event: InputEvent) -> void:
	if !_camera_pivot or !_camera_yaw:
		return;
	if event is InputEventMouseMotion:
		_camera_yaw.rotation.y -= event.relative.x * mouse_sensitivity
		# Prevent the camera from rotating too far up or down.
		_camera_pivot.rotation.x += -event.relative.y * mouse_sensitivity
		_camera_pivot.rotation.x = clampf(_camera_pivot.rotation.x, -tilt_limit, tilt_limit)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if (target):
		global_position=target.global_position;
	var cam_dir=Input.get_vector("ui_cam_left","ui_cam_right","ui_cam_up","ui_cam_down");
	if cam_dir:
		_camera_yaw.rotation.y -= deg_to_rad(cam_dir.x*gamepad_sensitivity*delta);
		# Prevent the camera from rotating too far up or down.
		_camera_pivot.rotation.x += deg_to_rad(cam_dir.y*gamepad_sensitivity*delta);
		_camera_pivot.rotation.x = clampf(_camera_pivot.rotation.x, -tilt_limit, tilt_limit)
	if (cursorCast):
		cursorCast.force_raycast_update();
		if (cursorCast.is_colliding() and canShowCursor):
			setCursor(true);
			$CameraPivot/PlayerCam/cursorCast/Sprite3D.global_position=cursorCast.get_collision_point()
		else:
			setCursor(false);
			
func setCursor(cursorState:bool):
	$CameraPivot/PlayerCam/cursorCast/Sprite3D.visible=cursorState;
