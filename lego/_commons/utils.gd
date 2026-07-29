extends Node3D

# Returns the closest angle accross thoses specified
func closest_angle(angle: float, allowedAngles: Array[float]) -> float :
	var normalizedAngle = fposmod(angle, 2 * PI)
	var closest = allowedAngles[0]
	var diff = abs(normalizedAngle - closest)
	for allowedAngle in allowedAngles :
		var currentDiff = abs(normalizedAngle - allowedAngle)
		if currentDiff < diff :
			closest = allowedAngle
			diff = currentDiff
	return closest

# Rotates a specified node around a pivot
func rotate_around_pivot(node: Node3D, pivot: Vector3, axis: Vector3, angle: float):
	var copy = node.global_transform
	copy.origin -= pivot
	copy.origin =copy.origin.rotated(axis.normalized(), angle)
	copy.origin += pivot
	copy.basis = copy.basis.rotated(axis.normalized(), angle)
	node.global_transform = copy

const GROUP_STICKY_FEMALE_SURFACE:String = "sticky_female_surfaces"
const GROUP_STICKY_MALE_SURFACE:String = "sticky_male_surfaces"
const GROUP_MALE_INSERTABLES:String = "male_insertables"
const GROUP_FEMALE_INSERTABLES:String = "female_insertables"

# Returns all the instantiated StickyMaleSurface
func getAllStickyMaleSurfaces() -> Array[StickyMaleSurface] :
	var surfaces: Array[StickyMaleSurface] = []
	for node in get_tree().get_nodes_in_group(GROUP_STICKY_MALE_SURFACE):
		if node is StickyMaleSurface:
			surfaces.append(node as StickyMaleSurface)
	return surfaces

# Returns all the instantiated StickyFemaleSurface
func getAllStickyFemaleSurfaces() -> Array[StickyFemaleSurface] :
	var surfaces: Array[StickyFemaleSurface] = []
	for node in get_tree().get_nodes_in_group(GROUP_STICKY_FEMALE_SURFACE):
		if node is StickyFemaleSurface:
			surfaces.append(node as StickyFemaleSurface)
	return surfaces

# Returns all the instantiated insertable male segments
func getAllMaleInsertableSegments() -> Array[InsertableMaleSegment] :
	var segments: Array[InsertableMaleSegment] = []
	for node in get_tree().get_nodes_in_group(GROUP_MALE_INSERTABLES):
		if node is InsertableMaleSegment:
			segments.append(node as InsertableMaleSegment)
	return segments

# Returns all the instantiated insertable female receivers
func getAllFemaleInsertableReceivers() -> Array[InsertableFemaleSegment] :
	var receivers: Array[InsertableFemaleSegment] = []
	for node in get_tree().get_nodes_in_group(GROUP_FEMALE_INSERTABLES):
		if node is InsertableFemaleSegment:
			receivers.append(node as InsertableFemaleSegment)
	return receivers

# Returns the angle between two given nodes
func getAngleBetweenNodes(nodeA: Node3D, nodeB: Node3D, axis: Vector3 = Vector3.UP) -> float:
	var from = nodeA.global_transform.basis.z.normalized()
	var to = nodeB.global_transform.basis.z.normalized()
	var cross = from.cross(to)
	var dot = from.dot(to)
	var saveAngle = from.angle_to(to)

	if cross.dot(axis) > 0:
		saveAngle = -saveAngle

	return saveAngle

func ray_intersect_object_from_camera(exceptions: Array) -> Dictionary :
	var space_state = get_world_3d().direct_space_state
	var cam = get_viewport().get_camera_3d()
	var mousepos = get_viewport().get_mouse_position()
	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * 10
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.exclude = exceptions
	query.collide_with_areas = true
	var result = space_state.intersect_ray(query) as Dictionary
	return result

func ray_intersect_plane_from_camera(planeHeight: float) -> Vector3 :
	var cam = get_viewport().get_camera_3d()
	var plane = Plane(Vector3.UP, planeHeight)
	var mousepos = get_viewport().get_mouse_position()
	var origin = cam.project_ray_origin(mousepos)
	var intersect = plane.intersects_ray(origin, cam.project_ray_normal(mousepos))
	if intersect :
		return intersect
	return Vector3.ZERO

func move_to_root(node: Node) -> void:
	var root = get_tree().get_current_scene()
	node.reparent(root)
	node.owner = root

func get_ancestors(node: Node) -> Array:
	var ancestors = []
	var current = node.get_parent()
	while current != null:
		ancestors.append(current)
		if current.get_parent() != get_tree().get_current_scene():
			current = current.get_parent()
		else:
			current = null
	return ancestors

func get_common_ancestor(node_a: Node, node_b: Node) -> Node:
	var ancestors_a = get_ancestors(node_a)
	var ancestors_b = get_ancestors(node_b)
	for ancestor in ancestors_a:
		if ancestor in ancestors_b:
			return ancestor
	return null

func is_mouse_over_ui() -> bool:
	return get_viewport().gui_get_hovered_control() != null
