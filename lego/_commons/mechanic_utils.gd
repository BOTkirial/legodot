extends Node

# renvoie la vitesse de rotation en rad/s
func get_current_speed_rads(inputVoltage: float, inputCurrent: float, ks: float) -> float :
	return (inputVoltage - inputCurrent) / ks

# renvoie le couple en Nm
func get_current_torque_nm(inputCurrent: float, kt: float) -> float :
	return inputCurrent * kt

# convertit une vitesse en rpm vers des rads
func rmp_to_rads(rpm:float) -> float :
	return rpm * 2 * PI / 60

# convertit une vitesse en rads vers des rpm
func rads_to_rpm(rads:float) -> float :
	return rads * 60 / (2 * PI)
