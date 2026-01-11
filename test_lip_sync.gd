extends Node

## Test script for lip sync analyzer
## This simulates audio input and tests viseme detection

func _ready():
	print("=== Victor Avatar Lip Sync Test ===")
	print("")
	
	# Test viseme name mapping
	print("Testing viseme names:")
	var analyzer = LipSyncAnalyzer.new()
	for i in range(9):
		var name = analyzer.get_viseme_name(i)
		print("  Viseme %d: %s" % [i, name])
	
	print("")
	print("Testing viseme detection with different amplitudes:")
	
	# Test with very low amplitude (should be SILENT)
	test_amplitude(analyzer, 0.01, "Low amplitude")
	
	# Test with medium amplitude (should trigger mouth movement)
	test_amplitude(analyzer, 0.05, "Medium amplitude")
	
	# Test with high amplitude (should trigger wide open)
	test_amplitude(analyzer, 0.15, "High amplitude")
	
	print("")
	print("All tests completed!")
	get_tree().quit()

func test_amplitude(analyzer: LipSyncAnalyzer, amplitude: float, description: String):
	# Simulate audio data with given amplitude
	var test_data = PackedVector2Array()
	for i in range(64):
		var value = sin(i * 0.1) * amplitude
		test_data.append(Vector2(value, value))
	
	var viseme = analyzer.determine_viseme(amplitude, test_data)
	var viseme_name = analyzer.get_viseme_name(viseme)
	print("  %s (%.3f): %s" % [description, amplitude, viseme_name])
