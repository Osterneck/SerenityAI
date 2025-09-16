# Meditation Audio Assets

This folder contains local meditation audio files that are bundled with the app. These files ensure the meditation music works reliably without depending on external URLs or internet connectivity.

## Audio Files Structure

### Required Files:
- `nature_sounds_15min.mp3` - 15-minute nature sounds meditation (forest ambiance, water, birds)
- `ambient_meditation_15min.mp3` - 15-minute ambient meditation music (ethereal tones, gentle harmonies)  
- `soft_instrumental_15min.mp3` - 15-minute soft instrumental meditation (piano, strings)
- `rain_sounds_10min.mp3` - 10-minute rain sounds meditation
- `ocean_waves_20min.mp3` - 20-minute ocean waves meditation

## Audio Specifications

### Recommended Format: MP3
- **Bitrate**: 128 kbps (good quality, reasonable file size)
- **Sample Rate**: 44.1 kHz
- **Channels**: Stereo
- **File Size**: Approximately 7-15 MB per file

### Alternative Format: M4A/AAC
- **Bitrate**: 128 kbps
- **Sample Rate**: 44.1 kHz  
- **Channels**: Stereo
- **File Size**: Approximately 5-12 MB per file

## Audio Content Guidelines

### Nature Sounds (15 min):
- Gentle forest ambiance
- Soft flowing water (stream/brook)
- Peaceful bird songs (not too prominent)
- Light wind through trees
- NO sudden or loud sounds

### Ambient Meditation (15 min):
- Soft ethereal tones
- Gentle harmonies
- Minimal melodic content
- Slow, gradual transitions
- Drone/pad-style background sounds

### Soft Instrumental (15 min):
- Gentle piano melodies
- Soft string sections
- Minimal percussion (if any)
- Slow tempo (60-80 BPM)
- Major keys preferred for relaxation

### Rain Sounds (10 min):
- Steady, gentle rainfall
- NO thunder or storms
- Consistent volume
- Natural rain rhythm

### Ocean Waves (20 min):
- Gentle wave sounds
- Consistent rhythm
- NO seagulls or other beach sounds
- Peaceful, continuous flow

## Implementation Details

The AudioService automatically loads these local assets instead of relying on external URLs. This ensures:

1. **Reliability** - Audio works without internet connection
2. **Performance** - No network delays or buffering
3. **Consistency** - Same experience across all users
4. **Privacy** - No external tracking or analytics

## File Placement

Place all audio files directly in the `assets/audio/` folder. The Flutter app will bundle these files and make them available through the asset system.

## Testing

After adding audio files:
1. Run `flutter clean`
2. Run `flutter pub get`
3. Test meditation player functionality
4. Verify audio plays correctly on both iOS and Android
5. Test offline functionality

## Fallback Behavior

If audio files fail to load, the app automatically falls back to timer mode while still providing the meditation session structure and UI.