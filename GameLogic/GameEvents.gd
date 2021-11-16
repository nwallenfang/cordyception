extends Node

signal dandelion_dialog
signal dandelion_attack

var EVENT_COUNTER: Dictionary = {}  # name -> int


func trigger_event(event_name: String):
	if EVENT_COUNTER.has(event_name):
		EVENT_COUNTER[event_name] += 1
	else:
		EVENT_COUNTER[event_name] = 1
		
	emit_signal(event_name)
	
func trigger_unique_event(event_name: String):
	if EVENT_COUNTER.has(event_name):
		return
		
	trigger_event(event_name)
	
