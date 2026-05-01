extends ProgressBar

@export var health: int

func _ready() -> void:
	self.max_value = health
	sync_health()

func hit():
	health -= 1
	sync_health()
	
func sync_health():
	self.value = health
