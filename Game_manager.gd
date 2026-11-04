extends Node

var keys = 0
var allKeys = false

func add_key():
	keys +=1
	print(keys)
func all_keys():
	if keys == 3:
		print("Máme všechny klíče")
		allKeys = true
