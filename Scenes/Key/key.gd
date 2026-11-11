extends Area2D

@onready var game_manager: Node = %Game_manager



func _on_body_entered(_body: Node2D) -> void:
	print("Coin")
	game_manager.add_key()
	queue_free() #pak nahradit za animationplayer kvuli zvukum, queue free zatim facha
