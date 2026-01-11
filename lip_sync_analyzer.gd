extends Node
class_name LipSyncAnalyzer

## Real-time lip sync analyzer that processes audio and determines mouth shapes
## Based on audio amplitude and frequency analysis

signal viseme_changed(viseme: String)

enum Viseme {
	SILENT,      # Mouth closed
	AA,          # "ah" - wide open
	EE,          # "ee" - wide smile
	OH,          # "oh" - rounded
	UW,          # "oo" - lips forward
	MM,          # "mm" - lips together
	FF,          # "ff" - teeth on lip
	TH,          # "th" - tongue between teeth
	SS           # "ss" - tight smile
}

# Audio analysis parameters
var audio_capture: AudioEffectCapture
var spectrum_analyzer: AudioEffectSpectrumAnalyzerInstance
var recording_index: int = 0

# Lip sync state
var current_viseme: Viseme = Viseme.SILENT
var viseme_threshold: float = 0.02  # Minimum amplitude to trigger mouth movement
var smoothing: float = 0.3  # Smoothing factor for transitions

# Audio buffer
var audio_buffer: PackedFloat32Array = PackedFloat32Array()
var buffer_size: int = 1024

func _ready():
	setup_audio_capture()

func setup_audio_capture():
	# Get the audio bus
	var record_bus_idx = AudioServer.get_bus_index("Record")
	
	# Try to find existing capture effect
	for i in range(AudioServer.get_bus_effect_count(record_bus_idx)):
		var effect = AudioServer.get_bus_effect(record_bus_idx, i)
		if effect is AudioEffectCapture:
			audio_capture = effect
			break
	
	if not audio_capture:
		push_warning("LipSyncAnalyzer: No AudioEffectCapture found on Record bus")

func _process(_delta):
	if not audio_capture:
		return
	
	# Get available frames from audio capture
	var available_frames = audio_capture.get_frames_available()
	
	if available_frames > 0:
		# Capture audio data
		var stereo_data = audio_capture.get_buffer(min(available_frames, buffer_size / 2))
		
		if stereo_data.size() > 0:
			analyze_audio(stereo_data)

func analyze_audio(stereo_data: PackedVector2Array):
	# Calculate average amplitude
	var amplitude: float = 0.0
	var sample_count: int = stereo_data.size()
	
	if sample_count == 0:
		return
	
	# Convert stereo to mono and calculate RMS amplitude
	for sample in stereo_data:
		var mono_sample = (sample.x + sample.y) / 2.0
		amplitude += mono_sample * mono_sample
	
	amplitude = sqrt(amplitude / sample_count)
	
	# Determine viseme based on amplitude and frequency characteristics
	var new_viseme = determine_viseme(amplitude, stereo_data)
	
	# Update current viseme if changed
	if new_viseme != current_viseme:
		current_viseme = new_viseme
		viseme_changed.emit(get_viseme_name(current_viseme))

func determine_viseme(amplitude: float, stereo_data: PackedVector2Array) -> Viseme:
	# If amplitude is too low, mouth is closed
	if amplitude < viseme_threshold:
		return Viseme.SILENT
	
	# Perform simple frequency analysis
	# Note: This is a simplified approach using time-domain sample grouping
	# For accurate frequency analysis, use AudioEffectSpectrumAnalyzer with FFT
	var low_freq_energy: float = 0.0
	var mid_freq_energy: float = 0.0
	var high_freq_energy: float = 0.0
	
	# Analyze first part of samples for rough frequency distribution
	# This groups early vs late samples as a proxy for frequency content
	var sample_count = min(stereo_data.size(), 64)
	for i in range(sample_count):
		var sample = (stereo_data[i].x + stereo_data[i].y) / 2.0
		var sample_squared = sample * sample
		
		# Rough frequency band separation
		if i < sample_count / 3:
			low_freq_energy += sample_squared
		elif i < 2 * sample_count / 3:
			mid_freq_energy += sample_squared
		else:
			high_freq_energy += sample_squared
	
	# Normalize
	low_freq_energy /= sample_count / 3.0
	mid_freq_energy /= sample_count / 3.0
	high_freq_energy /= sample_count / 3.0
	
	# Determine viseme based on frequency distribution and amplitude
	var total_energy = low_freq_energy + mid_freq_energy + high_freq_energy
	
	if total_energy < 0.0001:
		return Viseme.SILENT
	
	# High amplitude with strong low frequencies = "ah" sound (AA)
	if amplitude > viseme_threshold * 3 and low_freq_energy > mid_freq_energy:
		return Viseme.AA
	
	# High frequencies = sibilants (SS)
	if high_freq_energy > low_freq_energy and high_freq_energy > mid_freq_energy:
		return Viseme.SS
	
	# Mid frequencies with moderate amplitude = "ee" or "oh"
	if mid_freq_energy > low_freq_energy * 1.2:
		# Use mid_freq_energy threshold to determine EE vs OH
		if mid_freq_energy > high_freq_energy * 1.5:
			return Viseme.OH
		else:
			return Viseme.EE
	
	# Low to mid amplitude = lips together (MM)
	if amplitude < viseme_threshold * 2:
		return Viseme.MM
	
	# Default to open mouth
	return Viseme.AA

func get_viseme_name(viseme: Viseme) -> String:
	match viseme:
		Viseme.SILENT: return "silent"
		Viseme.AA: return "aa"
		Viseme.EE: return "ee"
		Viseme.OH: return "oh"
		Viseme.UW: return "uw"
		Viseme.MM: return "mm"
		Viseme.FF: return "ff"
		Viseme.TH: return "th"
		Viseme.SS: return "ss"
		_: return "silent"

func get_current_viseme() -> String:
	return get_viseme_name(current_viseme)
