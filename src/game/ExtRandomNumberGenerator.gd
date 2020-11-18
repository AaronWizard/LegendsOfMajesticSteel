class_name ExtRandomNumberGenerator
extends RandomNumberGenerator


func rand_array_element(array: Array):
	var index := randi_range(0, array.size() - 1)
	return array[index]
