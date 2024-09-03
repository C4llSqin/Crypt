extends RigidBody3D

var tags = {"type": "paper"}

func get_tags(): return tags

func get_text() -> String: return $text.text

func set_text(text: String): 
	$text.text = text # text text text
