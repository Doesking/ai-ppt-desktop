import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class AudioService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  
  bool _isRecorderInitialized = false;
  bool _isPlayerInitialized = false;
  bool _isRecording = false;
  String? _currentRecordingPath;
  
  /// Initialize audio service
  Future<void> initialize() async {
    await _initializeRecorder();
    await _initializePlayer();
  }
  
  Future<void> _initializeRecorder() async {
    if (_isRecorderInitialized) return;
    
    try {
      await _recorder.openRecorder();
      _isRecorderInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize recorder: $e');
    }
  }
  
  Future<void> _initializePlayer() async {
    if (_isPlayerInitialized) return;
    
    try {
      await _player.openPlayer();
      _isPlayerInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize player: $e');
    }
  }
  
  /// Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }
  
  /// Start recording audio
  Future<void> startRecording({String? outputPath}) async {
    if (!_isRecorderInitialized) {
      throw Exception('Recorder not initialized');
    }
    
    if (_isRecording) {
      throw Exception('Already recording');
    }
    
    // Request permission
    final hasPermission = await requestMicrophonePermission();
    if (!hasPermission) {
      throw Exception('Microphone permission denied');
    }
    
    // Determine output path
    final directory = outputPath ?? Directory.systemTemp.path;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = path.join(directory, 'recording_$timestamp.wav');
    
    try {
      await _recorder.startRecorder(
        toFile: filePath,
        codec: Codec.pcm16WAV,
        sampleRate: 16000,
        numChannels: 1,
      );
      
      _isRecording = true;
      _currentRecordingPath = filePath;
    } catch (e) {
      throw Exception('Failed to start recording: $e');
    }
  }
  
  /// Stop recording audio
  Future<String?> stopRecording() async {
    if (!_isRecording) {
      return null;
    }
    
    try {
      final filePath = await _recorder.stopRecorder();
      _isRecording = false;
      
      return filePath ?? _currentRecordingPath;
    } catch (e) {
      throw Exception('Failed to stop recording: $e');
    }
  }
  
  /// Play audio file
  Future<void> playAudio(String filePath) async {
    if (!_isPlayerInitialized) {
      throw Exception('Player not initialized');
    }
    
    try {
      await _player.startPlayer(
        fromURI: filePath,
        codec: Codec.pcm16WAV,
      );
    } catch (e) {
      throw Exception('Failed to play audio: $e');
    }
  }
  
  /// Stop audio playback
  Future<void> stopPlayback() async {
    if (!_isPlayerInitialized) return;
    
    try {
      await _player.stopPlayer();
    } catch (e) {
      throw Exception('Failed to stop playback: $e');
    }
  }
  
  /// Get audio file duration
  Future<Duration?> getAudioDuration(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return null;
      }
      
      // For WAV files, we can calculate duration from file size
      // This is a simplified implementation
      final fileSize = await file.length();
      final sampleRate = 16000; // Assuming 16kHz sample rate
      final channels = 1; // Assuming mono
      final bitsPerSample = 16; // Assuming 16-bit
      
      final bytesPerSecond = sampleRate * channels * (bitsPerSample ~/ 8);
      final durationSeconds = fileSize / bytesPerSecond;
      
      return Duration(milliseconds: (durationSeconds * 1000).round());
    } catch (e) {
      return null;
    }
  }
  
  /// Extract audio from video file
  Future<String?> extractAudioFromVideo(String videoPath) async {
    // This would typically use ffmpeg or similar
    // For now, we'll return a placeholder implementation
    throw UnimplementedError('Video audio extraction not yet implemented');
  }
  
  /// Check if currently recording
  bool get isRecording => _isRecording;
  
  /// Get current recording path
  String? get currentRecordingPath => _currentRecordingPath;
  
  /// Dispose resources
  Future<void> dispose() async {
    if (_isRecording) {
      await stopRecording();
    }
    
    if (_isPlayerInitialized) {
      await _player.closePlayer();
      _isPlayerInitialized = false;
    }
    
    if (_isRecorderInitialized) {
      await _recorder.closeRecorder();
      _isRecorderInitialized = false;
    }
  }
}

/// Audio processing result
class AudioProcessingResult {
  final String filePath;
  final Duration duration;
  final String? transcription;
  final List<String>? keyPoints;
  final Map<String, dynamic>? metadata;
  
  AudioProcessingResult({
    required this.filePath,
    required this.duration,
    this.transcription,
    this.keyPoints,
    this.metadata,
  });
}

/// Audio format enum
enum AudioFormat {
  wav,
  mp3,
  aac,
  m4a,
  ogg,
}

/// Audio quality enum
enum AudioQuality {
  low,      // 8kHz, 8-bit
  medium,   // 16kHz, 16-bit
  high,     // 44.1kHz, 16-bit
  studio,   // 48kHz, 24-bit
}