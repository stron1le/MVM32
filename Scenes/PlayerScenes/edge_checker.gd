extends Node3D
@onready var aboveCast :=$AboveCast as RayCast3D;
@onready var belowCast :=$BelowCast as RayCast3D;
@onready var parentNode = self.get_parent_node_3d();
var canSignal=false;
var ignore = [];
signal edgeDetected(normal);
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	aboveCast.force_raycast_update();
	belowCast.force_raycast_update();
	var edgeAbove = aboveCast.is_colliding();
	var edgeBelow=belowCast.is_colliding();
	if (!edgeAbove and edgeBelow):
		edgeDetected.emit(-1*transform.basis.z*belowCast.target_position.length())
func move_to_wall():
	if (!parentNode):
		pass;
		
