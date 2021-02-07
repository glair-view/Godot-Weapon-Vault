##############################################################################################################################################
## This work is marked with CC0 1.0 Universal. To view a copy of this license, visit http://creativecommons.org/publicdomain/zero/1.0       ##
##############################################################################################################################################


extends Node
class_name GVTween
######################################################################################################################################################
## USAGE!!                                                                                                                                          ##
##                                                                                                                                                  ##
## Multiply the return value of interpolate() by your desired maximum value and add your desired minimum value                                      ##
##                                                                                                                                                  ##
## Set min_value and max_value before using interpolate()                                                                                           ##
## To avoid potential errors, use set_min_max_value(), set_min_value(), and set_max_value() to update min_value and max_value or use the inspector  ##
## inside of the Godot Editor for initial values                                                                                                    ##
##                                                                                                                                                  ##
## Passing values under min_value to interpolate() will return the curve's value at position 0.0 unless extend_curve_below_minimum is set to true   ## 
## Passing values over max_value to interpolate() will return the curve's value at position 1.0 unless extend_curve_above_maximum is set to true    ##
## Passing values inbetween min_value and max_value to interpolate() will return the curve's value on a scale of min_value to max_value             ##
##                                                                                                                                                  ##
######################################################################################################################################################

export(Curve) var curve

# offset of curve = 0.0 at this value
export(float) var min_value = 0.0
# offset of curve = 1.0 at this value
export(float) var max_value = 1.0
# if enabled value of curve is inverted during interpolate()
export(bool) var invert = false
# if enable projects value of curve above 1.0 based on curve's angel else offset is capped at 1.0
export(bool) var extend_curve_above_maximum = false
# if enable projects value of curve below 0.0 based on curve's angle else offset is undercapped at 0.0
export(bool) var extend_curve_below_minimum = false


func _init(_min_value = 0.0, _max_value = 1.0):
	min_value = _min_value
	max_value = _max_value


# Getters and setters
func set_min_value(value : float) -> void:
	min_value = value

func get_min_value() -> float:
	return min_value

func set_max_value(value : float) -> void:
	max_value = value

func get_max_value() -> float:
	return max_value

func set_min_max_value(new_min_value, new_max_value) -> void:
	min_value = new_min_value
	max_value = new_max_value




func get_slope(position1 : Vector2, position2 : Vector2) -> float:
	return (position2.y - position1.y) / (position2.x - position1.x)

func calculate_offset(value : float) -> float:
	return (value - min_value) / (max_value - min_value)

func invert_if_set_to_invert(value : float) -> float:
	if invert:
		value = (value - 0.5) * -1 + 0.5
	return value

# projects values under 0.0 based on curves angle
func continue_curve_before(offset) -> float:
	var position1 : Vector2 = Vector2(0.0, curve.interpolate(0.0))
	var position2 : Vector2 = Vector2(0.0, curve.interpolate(0.01))
	var slope = get_slope(position1, position2)
	return slope * offset + position1.y

# projects values above 1.0 based on curves angle
func continue_curve_after(offset) -> float:
	var position1 : Vector2 = Vector2(0.99, curve.interpolate(0.99))
	var position2 : Vector2 = Vector2(1.0, curve.interpolate(1.0))
	var slope = get_slope(position1, position2)
	return slope * offset + position2.y


# returns y value of tween at offset on scale between 0.0 to 1.0 based on min_value to max_value 
# returns min/max value if offset is less/greater than min/max value
func interpolate(offset : float) -> float:
	var curve_value : float
	# check prevents Division by Zero
	if max_value == min_value:
		curve_value= curve.interpolate(0.0)
	else:
		offset = calculate_offset(offset)
		
		if offset < 0.0:
			if extend_curve_below_minimum:
				curve_value = continue_curve_before(offset)
			else:
				curve_value = curve.interpolate(0.0)
	
		elif offset > 1.0:
			if extend_curve_above_maximum:
				curve_value = continue_curve_after(offset)
			else:
				curve_value = curve.interpolate(1.0)
	
		else:
			curve_value = curve.interpolate(offset)
	
	return invert_if_set_to_invert(curve_value)
