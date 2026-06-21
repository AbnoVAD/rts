class_name NavigationRouteHelper
extends RefCounted

static func get_closest_nav_point(nav:NavigationAgent2D, pos:Vector2) -> Vector2:
	if nav==null or not is_instance_valid(nav):
		return pos
	var map:RID=nav.get_navigation_map()
	if map.is_valid():
		return NavigationServer2D.map_get_closest_point(map,pos)
	return pos

static func get_path_length(nav:NavigationAgent2D, from_pos:Vector2, to_pos:Vector2) -> float:
	if nav==null or not is_instance_valid(nav):
		return INF
	var map:RID=nav.get_navigation_map()
	if not map.is_valid():
		return from_pos.distance_to(to_pos)
	var start:=NavigationServer2D.map_get_closest_point(map,from_pos)
	var end:=NavigationServer2D.map_get_closest_point(map,to_pos)
	if start.distance_to(end)<=0.001:
		return 0.0
	var path:PackedVector2Array=NavigationServer2D.map_get_path(map,start,end,true,nav.navigation_layers)
	if path.size()<2:
		return INF
	var length:float=0.0
	for i in range(1,path.size()):
		length+=path[i-1].distance_to(path[i])
	return length

static func get_best_approach_point(nav:NavigationAgent2D, from_pos:Vector2, target_pos:Vector2, preferred_distance:float) -> Vector2:
	if nav==null or not is_instance_valid(nav):
		return target_pos
	var map:RID=nav.get_navigation_map()
	if not map.is_valid():
		return target_pos

	var toward_us:Vector2=(from_pos-target_pos).normalized()
	if toward_us==Vector2.ZERO:
		toward_us=Vector2.RIGHT
	var tangent:=Vector2(-toward_us.y,toward_us.x)
	var sample_distance:float=max(preferred_distance,max(nav.radius*2.0,24.0))

	var candidates:Array[Vector2]=[
		target_pos-toward_us*preferred_distance,
		target_pos-toward_us*sample_distance,
		target_pos+tangent*preferred_distance,
		target_pos-tangent*preferred_distance,
		target_pos+(toward_us+tangent).normalized()*sample_distance,
		target_pos+(toward_us-tangent).normalized()*sample_distance,
		target_pos+(-toward_us+tangent).normalized()*sample_distance,
		target_pos+(-toward_us-tangent).normalized()*sample_distance
	]

	var best_point:Vector2=get_closest_nav_point(nav,target_pos-toward_us*preferred_distance)
	var best_score:float=INF
	for candidate in candidates:
		var nav_point:=get_closest_nav_point(nav,candidate)
		var path_length:=get_path_length(nav,from_pos,nav_point)
		if path_length==INF:
			continue
		var score:=path_length+nav_point.distance_to(target_pos)*0.25
		if score<best_score:
			best_score=score
			best_point=nav_point

	return best_point

static func get_path_advance_point(nav:NavigationAgent2D, from_pos:Vector2, target_pos:Vector2, advance_distance:float) -> Vector2:
	if nav==null or not is_instance_valid(nav):
		return target_pos
	var map:RID=nav.get_navigation_map()
	if not map.is_valid():
		return target_pos

	var start:=NavigationServer2D.map_get_closest_point(map,from_pos)
	var end:=NavigationServer2D.map_get_closest_point(map,target_pos)
	var path:PackedVector2Array=NavigationServer2D.map_get_path(map,start,end,true,nav.navigation_layers)
	if path.size()<2:
		return end

	var remaining:float=max(advance_distance,nav.radius*3.0)
	for i in range(1,path.size()):
		var segment_length:float=path[i-1].distance_to(path[i])
		if segment_length<=0.001:
			continue
		if remaining<=segment_length:
			var t:float=remaining/segment_length
			return path[i-1].lerp(path[i],t)
		remaining-=segment_length

	return end

static func tune_navigation_agent(nav:NavigationAgent2D, travel_distance:float, near_path_distance:float, far_path_distance:float, near_target_distance:float, far_target_distance:float, near_radius:float, far_radius:float) -> void:
	if nav==null or not is_instance_valid(nav):
		return
	var blend:float=clampf(travel_distance/900.0,0.0,1.0)
	nav.path_desired_distance=lerp(near_path_distance,far_path_distance,blend)
	nav.target_desired_distance=lerp(near_target_distance,far_target_distance,blend)
	nav.radius=lerp(near_radius,far_radius,blend)
