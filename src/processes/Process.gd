class_name Process

signal finished


func run() -> void:
	print("Process: Must implement run()")
	emit_signal("finished")
