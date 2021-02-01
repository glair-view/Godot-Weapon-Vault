extends Node
class_name GVTween

export(Curve) var curve

export(float) var min_value = 0.0
export(float) var max_value = 1.0
# if enable value will be pojected past 1.0 based on curve's angel else value is capped at 1.0
export(bool) var project_tween_after = false
# if enable value will be projected under 0.0 based on curve's angle else value is undercapped at 0.0
export(bool) var project_tween_before

# Called when the node enters the scene tree for the first time.
func _ready():
	if min_value > max_value:
		push_error("Value Error: max_value set lesser than min_value at ready()")


# Getters and setters
func set_min_value(value : float) -> void:
	if value > max_value:
		push_error("Value Error: min_value set greater than max_value")
	min_value = value

func get_min_value() -> float:
	return min_value

func set_max_value(value : float) -> void:
	if value < min_value:
		push_error("Value Error: max_value set lesser than min_value")
	max_value = value

func get_max_value() -> float:
	return max_value

func set_minmax_value(min_value, max_value) -> void:
	if min_value > max_value:
		push_error("Value Error: max_value lesser than min_value")
	min_value = min_value
	max_value = max_value




func get_slope(position1 : Vector2, position2 : Vector2) -> float:
	return (position2.y - position1.y) / (position2.x - position1.x)
	
func calculate_offset(value : float) -> float:
	return (value - min_value) / (max_value - min_value)

# projects values under 0.0 based on curves angle
func continue_curve_before(offset) -> float:
	if offset < 1.0:
		push_warning("offset should be greater/equal to 1.0")
	var position1 : Vector2 = Vector2(0.0, curve.interpolate(0.0))
	var position2 : Vector2 = Vector2(0.0, curve.interpolate(0.01))
	var slope = get_slope(position1, position2)
	return slope * offset

# projects values over 1.0 based on curves angle
func continue_curve_after(offset) -> float:
	if offset < 1.0:
		push_warning("offset should be greater/equal to 1.0")
	var position1 : Vector2 = Vector2(0.99, curve.interpolate(0.99))
	var position2 : Vector2 = Vector2(1.0, curve.interpolate(1.0))
	var slope = get_slope(position1, position2)
	return slope * offset

# returns y value of tween at offset on scale between 0 and 1
# returns min/max value if offset is less/greater than min/max value
func interpolate(offset : float) -> float:
	offset = calculate_offset(offset)
	# if above or below min or max value return 0 or 1 respectively
	if offset < 0.0:
		if project_tween_before:
			return continue_curve_before(offset)
		offset = 0.0
	
	elif offset > 1.0:
		if project_tween_after:
			return continue_curve_after(offset)
		offset = 1.0
	
	# prevents division by zero error
	elif min_value == 0 and max_value == 0:
		offset = 1.0
	
	return curve.interpolate(offset)
