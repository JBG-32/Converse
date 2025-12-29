import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/settings_viewmodel.dart';
import '../../services/audio_service.dart';

/// Widget for configuring voice/speech settings
class VoiceSettings extends StatelessWidget {
    const VoiceSettings({super.key});

    @override
    Widget build(BuildContext context) {
          return Consumer<SettingsViewModel>(
                  builder: (context, viewModel, child) {
                            return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                                      _buildSectionTitle(context, 'Voice Settings'),
                                                      const SizedBox(height: 16),
                                                      _buildVoiceModeToggle(context, viewModel),
                                                      const SizedBox(height: 16),
                                                      _buildAutoSpeakToggle(context, viewModel),
                                                      const SizedBox(height: 24),
                                                      _buildSectionTitle(context, 'Speech Rate'),
                                                      const SizedBox(height: 8),
                                                      _buildSpeechRateSlider(context, viewModel),
                                                      const SizedBox(height: 24),
                                                      _buildSectionTitle(context, 'Voice Pitch'),
                                                      const SizedBox(height: 8),
                                                      _buildPitchSlider(context, viewModel),
                                                      const SizedBox(height: 24),
                                                      _buildSectionTitle(context, 'Language'),
                                                      const SizedBox(height: 8),
                                                      _buildLanguageSelector(context, viewModel),
                                                      const SizedBox(height: 24),
                                                      _buildSectionTitle(context, 'Voice Preview'),
                                                      const SizedBox(height: 8),
                                                      _buildVoicePreviewButton(context, viewModel),
                                                    ],
                                      );
                  },
                );
    }

    Widget _buildSectionTitle(BuildContext context, String title) {
          return Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                );
    }

    Widget _buildVoiceModeToggle(BuildContext context, SettingsViewModel viewModel) {
          return SwitchListTile(
                  title: const Text('Voice Mode'),
                  subtitle: const Text('Enable voice input for messages'),
                  value: viewModel.voiceModeEnabled,
                  onChanged: (value) => viewModel.setVoiceModeEnabled(value),
                  secondary: Icon(
                            viewModel.voiceModeEnabled ? Icons.mic : Icons.mic_off,
                            color: viewModel.voiceModeEnabled
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                );
    }

    Widget _buildAutoSpeakToggle(BuildContext context, SettingsViewModel viewModel) {
          return SwitchListTile(
                  title: const Text('Auto-Speak Responses'),
                  subtitle: const Text('Automatically speak AI responses aloud'),
                  value: viewModel.autoSpeakEnabled,
                  onChanged: (value) => viewModel.setAutoSpeakEnabled(value),
                  secondary: Icon(
                            viewModel.autoSpeakEnabled ? Icons.volume_up : Icons.volume_off,
                            color: viewModel.autoSpeakEnabled
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                );
    }

    Widget _buildSpeechRateSlider(BuildContext context, SettingsViewModel viewModel) {
          return Column(
                  children: [
                            Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                                      const Text('Slow'),
                                                      Text(_getSpeechRateLabel(viewModel.speechRate)),
                                                      const Text('Fast'),
                                                    ],
                                      ),
                            Slider(
                                        value: viewModel.speechRate,
                                        min: 0.25,
                                        max: 0.75,
                                        divisions: 10,
                                        label: _getSpeechRateLabel(viewModel.speechRate),
                                        onChanged: (value) => viewModel.setSpeechRate(value),
                                      ),
                            Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                                      _buildPresetButton(context, viewModel, 'Slow', 0.35),
                                                      _buildPresetButton(context, viewModel, 'Normal', 0.5),
                                                      _buildPresetButton(context, viewModel, 'Fast', 0.65),
                                                    ],
                                      ),
                          ],
                );
    }

    String _getSpeechRateLabel(double rate) {
          if (rate < 0.35) return 'Very Slow';
          if (rate < 0.45) return 'Slow';
          if (rate < 0.55) return 'Normal';
          if (rate < 0.65) return 'Fast';
          return 'Very Fast';
    }

    Widget _buildPresetButton(
          BuildContext context,
          SettingsViewModel viewModel,
          String label,
          double value,
        ) {
          final isSelected = (viewModel.speechRate - value).abs() < 0.05;
          return OutlinedButton(
                  onPressed: () => viewModel.setSpeechRate(value),
                  style: OutlinedButton.styleFrom(
                            backgroundColor: isSelected
                                ? Theme.of(context).colorScheme.primaryContainer
                                : null,
                          ),
                  child: Text(label),
                );
    }

    Widget _buildPitchSlider(BuildContext context, SettingsViewModel viewModel) {
          return Column(
                  children: [
                            Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                                      const Text('Low'),
                                                      Text('${viewModel.voicePitch.toStringAsFixed(1)}x'),
                                                      const Text('High'),
                                                    ],
                                      ),
                            Slider(
                                        value: viewModel.voicePitch,
                                        min: 0.5,
                                        max: 2.0,
                                        divisions: 15,
                                        label: '${viewModel.voicePitch.toStringAsFixed(1)}x',
                                        onChanged: (value) => viewModel.setVoicePitch(value),
                                      ),
                          ],
                );
    }

    Widget _buildLanguageSelector(BuildContext context, SettingsViewModel viewModel) {
          final languages = [
                  ('en-US', 'English (US)'),
                  ('en-GB', 'English (UK)'),
                  ('es-ES', 'Spanish'),
                  ('fr-FR', 'French'),
                  ('de-DE', 'German'),
                  ('it-IT', 'Italian'),
                  ('ja-JP', 'Japanese'),
                  ('ko-KR', 'Korean'),
                  ('zh-CN', 'Chinese (Simplified)'),
                  ('pt-BR', 'Portuguese (Brazil)'),
                ];

          return DropdownButtonFormField<String>(
                  value: viewModel.voiceLanguage,
                  decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                  items: languages.map((lang) {
                            return DropdownMenuItem(
                                        value: lang.$1,
                                        child: Text(lang.$2),
                                      );
                  }).toList(),
                  onChanged: (value) {
                            if (value != null) {
                                        viewModel.setVoiceLanguage(value);
                            }
                  },
                );
    }

    Widget _buildVoicePreviewButton(BuildContext context, SettingsViewModel viewModel) {
          return Row(
                  children: [
                            Expanded(
                                        child: OutlinedButton.icon(
                                                      onPressed: viewModel.isSpeaking
                                                          ? viewModel.stopSpeaking
                                                          : viewModel.testVoice,
                                                      icon: Icon(
                                                                      viewModel.isSpeaking ? Icons.stop : Icons.play_arrow,
                                                                    ),
                                                      label: Text(
                                                                      viewModel.isSpeaking ? 'Stop' : 'Test Voice',
                                                                    ),
                                                    ),
                                      ),
                            const SizedBox(width: 12),
                            if (viewModel.isSpeaking)
                              const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                          ],
                );
    }
}

/// Voice recording indicator widget
class VoiceRecordingIndicator extends StatefulWidget {
    final bool isListening;
    final double soundLevel;
    final VoidCallback? onTap;

    const VoiceRecordingIndicator({
          super.key,
          required this.isListening,
          this.soundLevel = 0,
          this.onTap,
    });

    @override
    State<VoiceRecordingIndicator> createState() => _VoiceRecordingIndicatorState();
}

class _VoiceRecordingIndicatorState extends State<VoiceRecordingIndicator>
      with SingleTickerProviderStateMixin {
    late AnimationController _animationController;
    late Animation<double> _pulseAnimation;

    @override
    void initState() {
          super.initState();
          _animationController = AnimationController(
                  vsync: this,
                  duration: const Duration(milliseconds: 1000),
                );
          _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
                  CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
                );

          if (widget.isListening) {
                  _animationController.repeat(reverse: true);
          }
    }

    @override
    void didUpdateWidget(VoiceRecordingIndicator oldWidget) {
          super.didUpdateWidget(oldWidget);
          if (widget.isListening && !oldWidget.isListening) {
                  _animationController.repeat(reverse: true);
          } else if (!widget.isListening && oldWidget.isListening) {
                  _animationController.stop();
                  _animationController.reset();
          }
    }

    @override
    void dispose() {
          _animationController.dispose();
          super.dispose();
    }

    @override
    Widget build(BuildContext context) {
          return GestureDetector(
                  onTap: widget.onTap,
                  child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                                        return Container(
                                                      width: 56,
                                                      height: 56,
                                                      decoration: BoxDecoration(
                                                                      shape: BoxShape.circle,
                                                                      color: widget.isListening
                                                                          ? Theme.of(context).colorScheme.error
                                                                          : Theme.of(context).colorScheme.primary,
                                                                      boxShadow: widget.isListening
                                                                          ? [
                                                                                                  BoxShadow(
                                                                                                                            color: Theme.of(context)
                                                                                                                                .colorScheme
                                                                                                                                .error
                                                                                                                                .withOpacity(0.4 * _pulseAnimation.value),
                                                                                                                            blurRadius: 16 * _pulseAnimation.value,
                                                                                                                            spreadRadius: 4 * _pulseAnimation.value,
                                                                                                                          ),
                                                                                                ]
                                                                          : null,
                                                                    ),
                                                      child: Transform.scale(
                                                                      scale: widget.isListening ? _pulseAnimation.value : 1.0,
                                                                      child: Icon(
                                                                                        widget.isListening ? Icons.stop : Icons.mic,
                                                                                        color: Colors.white,
                                                                                        size: 28,
                                                                                      ),
                                                                    ),
                                                    );
                            },
                          ),
                );
    }
}

/// Sound level visualizer (simple bar visualization)
class SoundLevelVisualizer extends StatelessWidget {
    final double level;
    final int barCount;
    final Color? activeColor;
    final Color? inactiveColor;

    const SoundLevelVisualizer({
          super.key,
          required this.level,
          this.barCount = 5,
          this.activeColor,
          this.inactiveColor,
    });

    @override
    Widget build(BuildContext context) {
          final theme = Theme.of(context);
          final active = activeColor ?? theme.colorScheme.primary;
          final inactive = inactiveColor ?? theme.colorScheme.surfaceVariant;

          // Normalize level to 0-1 range (sound levels typically -2 to 10 dB)
          final normalizedLevel = ((level + 2) / 12).clamp(0.0, 1.0);
          final activeBars = (normalizedLevel * barCount).ceil();

          return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(barCount, (index) {
                            final isActive = index < activeBars;
                            final height = 8.0 + (index * 4.0);

                            return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 2),
                                        child: AnimatedContainer(
                                                      duration: const Duration(milliseconds: 100),
                                                      width: 4,
                                                      height: height,
                                                      decoration: BoxDecoration(
                                                                      color: isActive ? active : inactive,
                                                                      borderRadius: BorderRadius.circular(2),
                                                                    ),
                                                    ),
                                      );
                  }),
                );
    }
}

/// Animated builder helper
class AnimatedBuilder extends StatelessWidget {
    final Animation<double> animation;
    final Widget Function(BuildContext, Widget?) builder;
    final Widget? child;

    const AnimatedBuilder({
          super.key,
          required this.animation,
          required this.builder,
          this.child,
    });

    @override
    Widget build(BuildContext context) {
          return AnimatedBuilder(
                  animation: animation,
                  builder: builder,
                  child: child,
                );
    }
}
