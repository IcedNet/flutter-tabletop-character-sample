// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:url_launcher/link.dart';

import 'package:character_creator/classes/classes.dart';
import 'package:character_creator/themes/theme.dart';
import 'package:character_creator/utils/util.dart';

void main() {
  runApp(const GenerativeAISample());
}

class GenerativeAISample extends StatelessWidget {
  const GenerativeAISample({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Cousine", "Grenze Gotisch");
    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Character Generator',
      theme: theme.light(),
      home: const ChatScreen(title: 'Character Generator'),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.title});

  final String title;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? apiKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
      ),
      body: switch (apiKey) {
        final providedKey? => ChatWidget(apiKey: providedKey),
        _ => ApiKeyWidget(onSubmitted: (key) {
            setState(() => apiKey = key);
          }),
      },
    );
  }
}

class ApiKeyWidget extends StatelessWidget {
  ApiKeyWidget({required this.onSubmitted, super.key});

  final ValueChanged onSubmitted;
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'To use the Gemini API, you\'ll need an API key. '
                'If you don\'t already have one, '
                'create a key in Google AI Studio.',
              ),
            ),
            const SizedBox(height: 8),
            Link(
              uri: Uri.https('aistudio.google.com', '/app/apikey'),
              target: LinkTarget.blank,
              builder: (context, followLink) => TextButton(
                onPressed: followLink,
                child: const Text('Get an API Key'),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration:
                          textFieldDecoration(context, 'Enter your API key'),
                      controller: _textController,
                      onSubmitted: (value) {
                        onSubmitted(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () {
                      onSubmitted(_textController.value.text);
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatWidget extends StatefulWidget {
  const ChatWidget({required this.apiKey, super.key});

  final String apiKey;

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  Future<Character>? characterResponse;
  late final CharacterService service;
  final descriptionController = TextEditingController();
  final roleController = TextEditingController();
  final personalityController = TextEditingController();
  final backgroundController = TextEditingController();

  @override
  void initState() {
    super.initState();
    service = CharacterService(widget.apiKey);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: SingleChildScrollView(
        child: (characterResponse == null)
            ? _buildForm(context)
            : FutureBuilder(
                future: characterResponse,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return _buildCharacterDisplay(context, snapshot.data!);
                  } else if (snapshot.hasError) {
                    return _buildErrorDisplay(context);
                  }

                  return _buildThinkingIndicator(context);
                },
              ),
      ),
    );
  }

  Widget _buildThinkingIndicator(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildForm(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Create additional NPCs for your group to interact with '
              'along their journey.'),
          const SizedBox(height: 32),
          Text('Describe the setting for your campaign',
              style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            decoration: textFieldDecoration(
              context,
              'In a far away land...',
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Suggest a role for this NPC',
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: roleController,
            decoration: textFieldDecoration(
              context,
              'A friendly tavern-keeper...',
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Describe their personality',
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: personalityController,
            decoration: textFieldDecoration(
              context,
              'Friendly, but aloof...',
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Where did they come from? What\'s their background?',
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: backgroundController,
            decoration: textFieldDecoration(
              context,
              'Raised on a dragon farm...',
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              child: const Text('Generate!'),
              onPressed: () {
                setState(() {
                  characterResponse = service.generateCharacter(
                      descriptionController.text,
                      personalityController.text,
                      roleController.text,
                      backgroundController.text);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterDisplay(BuildContext context, Character character) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              'assets/images/avatar.png',
              width: 300,
            ),
          ),
          _displayGeneratedCharacter(character, theme),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  characterResponse = null;
                });
              },
              child: const Text('Create another'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _displayGeneratedCharacter(Character character, ThemeData theme) {
    return SelectionArea(
        child: Column(
      children: [
        const SizedBox(height: 32),
        Text(
          character.name,
          style: theme.textTheme.displayLarge,
        ),
        const SizedBox(height: 32),
        Text(
          'Appearance',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 16),
        Text(
          'Age: ${character.appearance.age}',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Height: ${character.appearance.height}',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Weight: ${character.appearance.weight}',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Build: ${character.appearance.build}',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Hair: ${character.appearance.hair}',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Eyes: ${character.appearance.eyes}',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        Text(
          'Clothing',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 16),
        Text(
          character.clothing,
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        Text(
          'Accessories',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 16),
        Text(
          character.accessories,
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        Text(
          'Personality',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 16),
        Text(
          character.personality,
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        Text(
          'Role',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 16),
        Text(
          character.roleInGame,
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 32),
      ],
    ));
  }

  Widget _buildErrorDisplay(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Well, shoot.',
              style: theme.textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Something has gone wrong. Double check your network '
            'connection and API key, and then give it another try!',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  characterResponse = null;
                  descriptionController.clear();
                });
              },
              child: const Text('Try again'),
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration textFieldDecoration(BuildContext context, String hintText) =>
    InputDecoration(
      contentPadding: const EdgeInsets.all(15),
      hintText: hintText,
      hintStyle: Theme.of(context).textTheme.labelLarge,
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );

class CharacterService {
  final String apiKey;

  late final GenerativeModel model;

  final generationConfig = GenerationConfig(
    temperature: 0.4,
    topK: 32,
    topP: 1,
    maxOutputTokens: 4096,
  );

  final safetySettings = [
    SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
    SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
    SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
    SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
  ];

  CharacterService(this.apiKey) {
    model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  }

  Future<Character> generateCharacter(String description, String role,
      String personality, String background) async {
    final prompt = createPrompt(description, role, personality, background);

    int count = 0;

    while (count < 3) {
      try {
        final response = await model.generateContent(
          [prompt],
          safetySettings: safetySettings,
          generationConfig: generationConfig,
        );

        final json = jsonDecode(response.text!);
        final character = Character.fromJson(json);
        return character;
      } catch (ex) {
        debugPrint(ex.toString());
      }

      count++;
    }

    throw 'Could not parse response after three tries.';
  }
}
