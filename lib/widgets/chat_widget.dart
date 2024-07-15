import 'package:character_creator/classes/classes.dart';
import 'package:character_creator/utils/util.dart';
import 'package:flutter/material.dart';

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
