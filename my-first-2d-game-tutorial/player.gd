extends Area2D

signal hit #自定义一个信号

@export var speed = 400
var screen_size
var direction := Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	print(screen_size)
	hide()    #游戏开始时候隐藏玩家

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")  #自带斜量归一化处理
	var velocity = direction * speed * delta
	position += velocity
	position = position.clamp(Vector2.ZERO, screen_size)
	if direction.length() > 0:
		print(direction)
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		# See the note below about the following boolean assignment.
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0
		


func _on_body_entered(body: Node2D) -> void:
	hide() # Player disappears after being hit.
	hit.emit()              #发出这个信号
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)      #hide() 只是看不见，碰撞体还生效，须额外关闭CollisionShape2D
														   #敌人每次击中 玩家时都会发出一个信号。
														   #我们需要禁用玩家的碰撞检测，确保我们不会多次触发 hit 信号。
#如果在引擎的碰撞处理过程中禁用区域的碰撞形状可能会导致错误。使用 set_deferred() 告诉 Godot 等待可以安全地禁用形状时再这样做。


func start(pos):            #用于在开始新游戏时调用来重置玩家
	position = pos
	show()
	$CollisionShape2D.disabled = false
