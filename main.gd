extends Control

## Main scene for Victor Avatar with lip-sync demonstration

@onready var victor: VictorAvatar = $VictorAvatar
@onready var status_label: Label = $UI/StatusLabel
@onready var start_button: Button = $UI/ButtonContainer/StartButton
@onready var stop_button: Button = $UI/ButtonContainer/StopButton
@onready var viseme_label: Label = $UI/VisemeLabel
@onready var info_label: Label = $UI/InfoLabel

var audio_recording: bool = false
var playback: AudioStreamPlayer

func _ready():
	# Setup UI
	stop_button.disabled = true
	
	# Connect signals
	start_button.pressed.connect(_on_start_pressed)
	stop_button.pressed.connect(_on_stop_pressed)
	
	# Setup audio buses
	setup_audio_buses()
	
	# Connect to lip sync updates
	if victor and victor.lip_sync:
		victor.lip_sync.viseme_changed.connect(_on_viseme_changed)
	
	update_status("Ready. Click 'Start Microphone' to begin.")

func setup_audio_buses():
	# Create a Record bus if it doesn't exist
	var record_bus_idx = AudioServer.get_bus_index("Record")
	
	if record_bus_idx == -1:
		# Add Record bus
		AudioServer.add_bus(1)
		AudioServer.set_bus_name(1, "Record")
		record_bus_idx = 1
	
	# Add AudioEffectCapture to Record bus
	var capture_effect = AudioEffectCapture.new()
	capture_effect.buffer_length = 0.1  # 100ms buffer
	AudioServer.add_bus_effect(record_bus_idx, capture_effect, 0)
	
	# Create AudioStreamPlayer for recording
	playback = AudioStreamPlayer.new()
	add_child(playback)
	playback.bus = "Record"

func _on_start_pressed():
	# Start recording from microphone
	var recording_stream = AudioStreamMicrophone.new()
	playback.stream = recording_stream
	playback.play()
	
	audio_recording = true
	start_button.disabled = true
	stop_button.disabled = false
	
	update_status("Listening to microphone... Speak to see Victor's lips move!")

func _on_stop_pressed():
	# Stop recording
	if playback:
		playback.stop()
	
	audio_recording = false
	start_button.disabled = false
	stop_button.disabled = true
	
	update_status("Microphone stopped. Click 'Start Microphone' to resume.")

func _on_viseme_changed(viseme: String):
	viseme_label.text = "Current Viseme: " + viseme.to_upper()

func update_status(text: String):
	if status_label:
		status_label.text = text

func _process(_delta):
	# Update info with FPS
	if info_label:
		info_label.text = "FPS: " + str(Engine.get_frames_per_second())
