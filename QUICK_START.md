# Quick Start Guide - Victor Avatar Lip Sync

## What is this?

Victor is a 2D animated avatar in Godot that moves his mouth in real-time as you speak into your microphone, creating the illusion of a living character.

## How to Use

### Step 1: Open the Project
1. Download and install [Godot 4.2 or later](https://godotengine.org/download)
2. Open Godot
3. Click "Import" and select the `project.godot` file
4. Click "Import & Edit"

### Step 2: Run the Project
1. Press **F5** or click the **Play** button (▶️) in the top-right
2. The Victor Avatar window will appear

### Step 3: Enable Microphone
1. Click the **"Start Microphone"** button
2. If prompted, allow microphone access
3. You should see "Listening to microphone..." status

### Step 4: Speak!
1. Speak or make sounds into your microphone
2. Watch Victor's mouth animate in real-time
3. The current viseme (mouth shape) is displayed at the top

### Step 5: Stop
1. Click **"Stop Microphone"** when done
2. Close the window or press **F8** to stop

## What to Expect

- **Louder sounds** = wider mouth opening
- **Quiet sounds** = subtle mouth movements
- **High-pitched sounds** = tight mouth shapes
- **Low-pitched sounds** = open mouth shapes
- Victor also blinks naturally every few seconds!

## Troubleshooting

**Problem:** Mouth doesn't move
- Solution: Check microphone is plugged in and working
- Solution: Try speaking louder
- Solution: Verify microphone permissions were granted

**Problem:** Movements are jerky
- Solution: This is normal for the simplified version
- Solution: Try speaking more smoothly

**Problem:** Can't start microphone
- Solution: Check Godot has microphone permissions in system settings
- Solution: Try restarting the project

## What's Happening Behind the Scenes?

1. **Audio Capture**: Your microphone captures sound
2. **Analysis**: The system measures how loud and what pitch
3. **Viseme Selection**: It picks a mouth shape (viseme) that matches
4. **Animation**: Victor's mouth smoothly changes shape

## Visemes Explained

Victor can make these mouth shapes:

- **SILENT**: Mouth closed (no sound detected)
- **AA**: Wide open (like saying "ah")
- **EE**: Wide smile (like saying "eee")
- **OH**: Round mouth (like saying "oh")
- **MM**: Lips together (like humming)
- **SS**: Tight smile (like "sss" sounds)

## Fun Things to Try

1. **Sing a song** - Watch Victor sing along!
2. **Read a story** - Victor becomes your narrator
3. **Different volumes** - Whisper vs. shouting creates different animations
4. **Different pitches** - Try high and low voices
5. **Sound effects** - Make random noises and see what happens!

## Technical Details (For Developers)

- **Engine**: Godot 4.2
- **Language**: GDScript
- **Audio**: Real-time microphone capture with AudioEffectCapture
- **Analysis**: Amplitude and frequency-based viseme detection
- **Rendering**: 2D polygon-based character
- **Frame Rate**: 60 FPS target

## Project Files

- `main.tscn` - Main scene with UI
- `victor_avatar.tscn` - Victor character
- `lip_sync_analyzer.gd` - Audio analysis logic
- `victor_avatar.gd` - Animation logic
- `main.gd` - UI and microphone control

## Need More Help?

See the full `IMPLEMENTATION_GUIDE.md` for detailed technical information.

---

**Enjoy bringing Victor to life! 🎤✨**
