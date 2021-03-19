extends Node


func array_from_vec3(vec : Vector3) -> Array:
	return [vec.x, vec.y, vec.z]
	

func vec3_from_array(arr : Array) -> Vector3:
	return Vector3(arr[0], arr[1], arr[2])


func array_from_transform(transform : Transform) -> Array:
	var origin = array_from_vec3(transform.origin)
	var basis = array_from_basis(transform.basis)
	return origin + basis
	
	
func array_from_basis(basis : Basis) -> Array:
	return [
		basis.x.x, basis.x.y, basis.x.z,
		basis.y.x, basis.y.y, basis.y.z,
		basis.z.x, basis.z.y, basis.z.z
	]


func basis_from_array(arr : Array) -> Basis:
	return Basis(
		Vector3(arr[0], arr[1], arr[2]),
		Vector3(arr[3], arr[4], arr[5]),
		Vector3(arr[6], arr[7], arr[8])
	)
	
	
func transform_from_array(arr : Array) -> Transform:
	var origin = vec3_from_array(arr.slice(0, 2))
	var basis = basis_from_array(arr.slice(3, 11))
	return Transform(basis, origin)


func shallow_dict_merge(from, to):
	for key in from.keys():
		to[key] = from[key]
		
	return to
	

func linear_interpolation(x, x0, y0, x1, y1):
	# Simple linear interpolator
	# https://en.wikipedia.org/wiki/Linear_interpolation
	return (y0 * (x1 - x) + y1 * (x - x0)) / (x1 - x0)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
