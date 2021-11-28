extends Node

# act 1
signal dandelion_dialog
signal dandelion_attack
signal dandelion_attack_over
signal joke_dialog
signal joke_attack

# act 2
signal shroom_fist_dialog
signal shroom_dash_learned
signal scout_dialog
signal small_chase
signal stick_close
signal room_checkpoint
signal room_cutscene

# arena
signal learn_shoot
signal arena_wave1
signal arena_wave2
signal shroom_to_shroom_talk
signal trigger_phoridae
signal trigger_thorn_shooter
signal thorn_camera

# boss
signal begin_boss
signal begin_boss_cutscene_ended

signal enemy_died
signal player_died
signal checkpoint_collected
signal grass_rustle

var EVENT_COUNTER: Dictionary = {}  # name -> int 

# for events that don't reset upon death
var PERSISTENT_EVENT_COUNTER: Dictionary = {}

# Dictionary event_name (String) -> list of (count (int), Node caller_node, String caller_method_name) 3-tuples
var OBSERVER_DICT: Dictionary = {}

func increase_counter(event_name):
	if EVENT_COUNTER.has(event_name):
		EVENT_COUNTER[event_name] += 1
	else:
		EVENT_COUNTER[event_name] = 1
		
	print("event: ", event_name, ": ", EVENT_COUNTER[event_name])
	check_observers(event_name)

		
var node: Node
var method: String
var actual_count: int
var observer_count: int
func check_observers(event_name):
	# if there are events that are waiting (observing) for an event to reach
	# a certain count (e.g. player has killed 3 enemies) these events will be
	# found in EVENT_OBSERVER_DICT. if the count is reached the method passed
	# from connect_to_event_count will be called
	if OBSERVER_DICT.has(event_name): 
		var observer_list: Array = OBSERVER_DICT[event_name]
		actual_count = EVENT_COUNTER[event_name]

		for observer in observer_list:
			if observer["event_count"] == actual_count:
				observer["object"].call(observer["method_name"])
			
func count(event_name: String):
	if EVENT_COUNTER.has(event_name):
		return EVENT_COUNTER[event_name]
	else:
		return 0

func trigger_event(event_name: String):
	increase_counter(event_name)
	emit_signal(event_name)

func trigger_event_with_arg(event_name: String, arg):
	increase_counter(event_name)
	emit_signal(event_name, arg)
	
func trigger_unique_event(event_name: String):
	if EVENT_COUNTER.has(event_name):
		return
	trigger_event(event_name)
	
func trigger_unique_event_with_arg(event_name: String, arg):
	if EVENT_COUNTER.has(event_name):
		return
	trigger_event_with_arg(event_name, arg)


func connect_to_event_count(event_name: String, event_count: int, object: Node, method_name: String):
	if OBSERVER_DICT.has(event_name):
		OBSERVER_DICT[event_name].append({"event_count": event_count, "object": object, "method_name": method_name})
	else:
		OBSERVER_DICT[event_name] = [{"event_count": event_count, "object": object, "method_name": method_name}]
