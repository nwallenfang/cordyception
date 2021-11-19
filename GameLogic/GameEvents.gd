extends Node

signal dandelion_dialog
signal dandelion_attack
signal dandelion_attack_over
signal enemy_died
signal player_died
signal checkpoint_collected
signal grass_rustle

var EVENT_COUNTER: Dictionary = {}  # name -> int 


func trigger_event(event_name: String):
	if EVENT_COUNTER.has(event_name):
		EVENT_COUNTER[event_name] += 1
	else:
		EVENT_COUNTER[event_name] = 1
		
	emit_signal(event_name)
	
	
func trigger_event_with_arg(event_name: String, arg):
	if EVENT_COUNTER.has(event_name):
		EVENT_COUNTER[event_name] += 1
	else:
		EVENT_COUNTER[event_name] = 1
		
	emit_signal(event_name, arg)
	
func trigger_unique_event(event_name: String):
	if EVENT_COUNTER.has(event_name):
		return
		
	trigger_event(event_name)
	
