extends Node

var keys = 0
var allKeys = false

var hp = 100


func add_key():
	keys +=1
	print(keys)
func all_keys():
	if keys == 3:
		print("Máme všechny klíče")
		allKeys = true

func hit():
	hp -=20
	
	print(hp)
	if hp <=0:
		get_tree().reload_current_scene()
