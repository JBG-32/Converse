import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/settings_viewmodel.dart';
import '../../core/constants/api_constants.dart';

class SettingsView extends StatelessWidget {
    const SettingsView({super.key});

    @override
    Widget build(BuildContext context) {
          return Scaffold(
                  appBar: AppBar(
                            title: const Text('Settings'),
                          ),
                  body: Consumer<SettingsViewModel>(
                            builder: (context, viewModel, child) {
                                        return ListView(
                                                      padding: const EdgeInsets.all(16),
                                                      children: [
                                                                      _buildSection(
                                                                                        context,
                                                                                        title: 'Appearance',
                                                                                        children: [
                                                                                                            _buildThemeSelector(context, viewModel),
                                                                                                          ],
                                                                                      ),
                                                                      const SizedBox(height: 24),
                                                                      _buildSection(
                                                                                        context,
                                                                                        title: 'API Configuration',
                                                                                        children: [
                                                                                                            _buildApiKeyField(context, viewModel),
                                                                                                            const SizedBox(height: 16),
                                                                                                            _buildModelSelector(context, viewModel),
                                                                                                          ],
                                                                                      ),
                                                                      const SizedBox(height: 24),
                                                                      _buildSection(
                                                                                        context,
                                                                                        title: 'Voice Settings',
                                                                                        children: [
                                                                                                            _buildAutoSpeakToggle(context, viewModel),
                                                                                                            const SizedBox(height: 16),
                                                                                                            _buildSpeechRateSlider(context, viewModel),
                                                                                                            const SizedBox(height: 16),
                                                                                                            _buildPitchSlider(context, viewModel),
                                                                                                          ],
                                                                                      ),
                                                                      const SizedBox(height: 24),
                                                                      _buildSection(
                                                                                        context,
                                                                                        title: 'About',
                                                                                        children: [
                                                                                                            _buildAboutInfo(context),
                                                                                                          ],
                                                                                      ),
                                                                    ],
                                                    );
                            },
                          ),
                );
    }

    Widget _buildSection(
          BuildContext context, {
                required String title,
                required List<Widget> children,
          }) {
          return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                            Text(
                                        title,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                      ),
                            const SizedBox(height: 12),
                            Card(
                                        child: Padding(
                                                      padding: const EdgeInsets.all(16),
                                                      child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: children,
                                                                    ),
                                                    ),
                                      ),
                          ],
                );
    }

    Widget _buildThemeSelector(BuildContext context, SettingsViewModel viewModel) {
          return Row(
                  children: [
                            const Icon(Icons.palette),
                            const SizedBox(width: 16),
                            const Expanded(child: Text('Theme')),
                            DropdownButton<ThemeMode>(
                                        value: viewModel.themeMode,
                                        onChanged: (mode) {
                                                      if (mode != null) viewModel.setThemeMode(mode);
                                        },
                                        items: const [
                                                      DropdownMenuItem(
                                                                      value: ThemeMode.system,
                                                                      child: Text('System'),
                                                                    ),
                                                      DropdownMenuItem(
                                                                      value: ThemeMode.light,
                                                                      child: Text('Light'),
                                                                    ),
                                                      DropdownMenuItem(
                                                                      value: ThemeMode.dark,
                                                                      child: Text('Dark'),
                                                                    ),
                                                    ],
                                      ),
                          ],
                );
    }

    Widget _buildApiKeyField(BuildContext context, SettingsViewModel viewModel) {
          return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                            Row(
                                        children: [
                                                      const Icon(Icons.key),
                                                      const SizedBox(width: 16),
                                                      const Text('API Key'),
                                                      const Spacer(),
                                                      if (viewModel.hasApiKey)
                                                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                                    ],
                                      ),
                            const SizedBox(height: 8),
                            TextField(
                                        obscureText: true,
                                        decoration: InputDecoration(
                                                      hintText: viewModel.hasApiKey ? '••••••••••••••••' : 'Enter your API key',
                                                      border: const OutlineInputBorder(),
                                                      suffixIcon: IconButton(
                                                                      icon: const Icon(Icons.save),
                                                                      onPressed: () {},
                                                                    ),
                                                    ),
                                        onSubmitted: (value) {
                                                      if (value.isNotEmpty) {
                                                                      viewModel.setApiKey(value);
                                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                                                        const SnackBar(content: Text('API key saved')),
                                                                                      );
                                                      }
                                        },
                                      ),
                            const SizedBox(height: 8),
                            Text(
                                        'Your API key is stored securely on your device.',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                          ],
                );
    }

    Widget _buildModelSelector(BuildContext context, SettingsViewModel viewModel) {
          return Row(
                  children: [
                            const Icon(Icons.smart_toy),
                            const SizedBox(width: 16),
                            const Expanded(child: Text('Model')),
                            DropdownButton<String>(
                                        value: viewModel.selectedModel,
                                        onChanged: (model) {
                                                      if (model != null) viewModel.setSelectedModel(model);
                                        },
                                        items: viewModel.availableModels.map((model) {
                                                      return DropdownMenuItem(
                                                                      value: model,
                                                                      child: Text(ApiConstants.getModelDisplayName(model)),
                                                                    );
                                        }).toList(),
                                      ),
                          ],
                );
    }

    Widget _buildAutoSpeakToggle(BuildContext context, SettingsViewModel viewModel) {
          return Row(
                  children: [
                            const Icon(Icons.volume_up),
                            const SizedBox(width: 16),
                            const Expanded(child: Text('Auto-speak responses')),
                            Switch(
                                        value: viewModel.autoSpeak,
                                        onChanged: viewModel.setAutoSpeak,
                                      ),
                          ],
                );
    }

    Widget _buildSpeechRateSlider(BuildContext context, SettingsViewModel viewModel) {
          return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                            Row(
                                        children: [
                                                      const Icon(Icons.speed),
                                                      const SizedBox(width: 16),
                                                      Text('Speech Rate: ${viewModel.speechRate.toStringAsFixed(1)}x'),
                                                    ],
                                      ),
                            Slider(
                                        value: viewModel.speechRate,
                                        min: 0.5,
                                        max: 2.0,
                                        divisions: 15,
                                        onChanged: viewModel.setSpeechRate,
                                      ),
                          ],
                );
    }

    Widget _buildPitchSlider(BuildContext context, SettingsViewModel viewModel) {
          return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                            Row(
                                        children: [
                                                      const Icon(Icons.tune),
                                                      const SizedBox(width: 16),
                                                      Text('Pitch: ${viewModel.pitch.toStringAsFixed(1)}'),
                                                    ],
                                      ),
                            Slider(
                                        value: viewModel.pitch,
                                        min: 0.5,
                                        max: 2.0,
                                        divisions: 15,
                                        onChanged: viewModel.setPitch,
                                      ),
                          ],
                );
    }

    Widget _buildAboutInfo(BuildContext context) {
          return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                            Row(
                                        children: [
                                                      const Icon(Icons.info_outline),
                                                      const SizedBox(width: 16),
                                                      const Text('Converse'),
                                                      const Spacer(),
                                                      Text(
                                                                      'v1.0.0',
                                                                      style: Theme.of(context).textTheme.bodySmall,
                                                                    ),
                                                    ],
                                      ),
                            const SizedBox(height: 12),
                            Text(
                                        'A voice-powered chat application for conversing with AI.',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                            const SizedBox(height: 12),
                            TextButton(
                                        onPressed: () {
                                                      // TODO: Open GitHub repo
                                        },
                                        child: const Text('View on GitHub'),
                                      ),
                          ],
                );
    }
}
