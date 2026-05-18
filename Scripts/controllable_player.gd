extends CharacterBody3D


const SPEED = 5.0
const ACCEL = 10.0;
const BRAKE = 5.0;
const JUMP_VELOCITY = 8

var state="Grounded";
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		if state!="LedgeGrab":
			velocity += get_gravity() * delta
	match(state):
		"Grounded":
			# Handle jump.
			if Input.is_action_just_pressed("ui_accept") and is_on_floor():
				velocity.y = JUMP_VELOCITY
			# Get the input direction and handle the movement/deceleration.
			# As good practice, you should replace UI actions with custom gameplay actions.
			var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
			var moveTransform = get_cam_transform();
			var target_direction = (moveTransform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
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
				state="Grounded";
			else:
				var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
				var target_direction = (get_cam_transform().basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
				if (target_direction and target_direction.angle_to(-$EdgeChecker.basis.z)>deg_to_rad(150)):
					velocity.y=0;
					state="Grounded";
					print("Exit");
func _on_edge_checker_edge_detected(forwardDirection):
	if !is_on_floor() and velocity.y<0:
		var savedPosition=global_position;
		var collisionInfo = move_and_collide(forwardDirection);
		if (collisionInfo):
			if (collisionInfo.get_normal().y!=0):
				global_position=savedPosition;
				return;
			$EdgeChecker.look_at($EdgeChecker.global_position-collisionInfo.get_normal())
		$EdgeChecker/DownCast.force_raycast_update();
		if ($EdgeChecker/DownCast.is_colliding()):
			velocity=Vector3.ZERO;
			global_position.y=$EdgeChecker/DownCast.get_collision_point().y-2;
			state="LedgeGrab";
			print("I'm on a ledge")
		else:
			global_position=savedPosition;
	pass # Replace with function body.
func get_cam_transform():
	if (get_viewport().get_camera_3d()==Player_Cam.singleton._camera):
		return Player_Cam.singleton.transform;
	else:
		var currentCam = get_viewport().get_camera_3d().transform;
		var newTransform = Transform3D();
		var newCamBasis = Basis();
		newCamBasis.z=currentCam.basis.z;
		newCamBasis.z.y=0;
		newCamBasis.x.y=0;
		newCamBasis=newCamBasis.orthonormalized();
		newTransform.basis=newCamBasis;
		return newTransform;
