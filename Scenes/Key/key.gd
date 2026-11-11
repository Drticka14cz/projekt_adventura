extends Area2D

@onready var game_manager: Node = %Game_manager
@onready var sfx_coin: AudioStreamPlayer2D = $"../sfx_coin"



func _on_body_entered(body: Node2D) -> void:
	print("Coin")
	sfx_coin.play()
	game_manager.add_key()
	queue_free() #pak nahradit za animationplayer kvuli zvukum, queue free zatim facha
