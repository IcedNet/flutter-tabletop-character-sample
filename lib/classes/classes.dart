import 'dart:convert';

import 'package:character_creator/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:url_launcher/link.dart';

class Appearance {
  final String age;
  final String height;
  final String weight;
  final String build;
  final String hair;
  final String eyes;

  const Appearance({
    required this.age,
    required this.height,
    required this.weight,
    required this.build,
    required this.hair,
    required this.eyes,
  });

  Appearance.fromJson(Map<String, dynamic> json)
      : age = json['age'] ?? '',
        height = json['height'] ?? '',
        weight = json['weight'] ?? '',
        build = json['build'] ?? '',
        hair = json['hair'] ?? '',
        eyes = json['eyes'] ?? '';
}

class Character {
  final String name;
  final Appearance appearance;
  final String clothing;
  final String accessories;
  final String personality;
  final String roleInGame;

  const Character({
    required this.name,
    required this.appearance,
    required this.clothing,
    required this.accessories,
    required this.personality,
    required this.roleInGame,
  });

  Character.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        appearance = Appearance.fromJson(json['appearance']),
        clothing = json['clothing'] ?? '',
        accessories = json['accessories'] ?? '',
        personality = json['personality'] ?? '',
        roleInGame = json['roleInGame'] ?? '';
}

const example1 = '''
<user>
{
  "description": "Cozy cottage, whimsical, natural"
  "personality": "Strong backbone, pragmatic, caring, wise and knowledgable"
  "role": "The Village Herbalist"
  "background": "Grew up exploring the forests of her home village. Lives in a secluded cottage which doubles as her alchemical workshop."
}
</user>
<model>
{
  "name": "Elara",
  "appearance": {
    "age": "Mid-50s, with laugh lines around her eyes and streaks of grey in her warm brown hair, often braided and adorned with wildflowers.",
    "height": "5'11\\"",
    "weight": "155",
    "build": "Slender yet strong from years of tending her garden and foraging in the nearby woods.",
    "hair": "Silver, like the moon.",
    "eyes": "Blue, like the sea."
  },
  "clothing": "Elara prefers practical, earth-toned garments made from natural fabrics like linen and wool.  She often wears a long, flowy skirt, a fitted bodice, and a shawl or apron with pockets overflowing with seeds, dried herbs, and small tools.",
  "accessories": "Always barefoot with dirt under her fingernails. Her hands often bear the green stains of crushed leaves and berries.  A simple leather cord necklace with a polished river stone pendant hangs around her neck.",
  "personality": "Elara possesses a deep love for all living things and is always willing to lend a hand or offer a calming word. Years of studying the natural world have granted her extensive knowledge of plants, their medicinal properties, and the delicate balance of the ecosystem. Elara is self-sufficient and comfortable living a simple life close to nature.  She is a skilled herbalist, gardener, and forager, able to utilize the gifts of the land to provide for herself and others. She feels a strong connection to the earth and the magical energy that flows through it.  She often incorporates folklore and ancient rituals into her herbal practice.",
  "roleInGame": "Players can visit Elara to purchase healing remedies, salves, and teas crafted from her garden. Elara may ask the player to help her gather rare herbs, protect sacred natural sites, or even assist with local wildlife. Through conversations, she reveals snippets of local history, folklore, and wisdom about the interconnectedness of all things. Elara's gentle wisdom and deep connection to nature can offer the player guidance and perspective when making difficult choices."
}
</model>
''';

const example2 = '''
<user>
{
  "description": "Magical Renaissance Faire"
  "personality": "Entertaining, quick with a joke, adventurous"
  "role": "The Wandering Bard"
  "background": "A nomadic collector of magical musical instruments."
}
</user>
<model>
{
  "name": "Lark",
  "appearance": {
    "age": "Early 20s, with a youthful appearance and a mischievous twinkle in their eyes.",
    "height": "6'1\\"",
    "weight": "180",
    "build": "Lark has a lithe and agile frame, well-suited to their nomadic lifestyle.",
    "hair": "Silver, like the moon.",
    "eyes": "Blue, like the sea."
  },
  "clothing": "They favor comfortable and practical attire, often layered and mismatched, reflecting the various places they've visited. Think loose trousers, a tunic, a colorful scarf, and a well-worn cloak adorned with trinkets and charms gathered from their travels.",
  "accessories": "Lark always carries their trusty lute, often decorated with carvings and colorful ribbons. They might have an assortment of small instruments tucked into their belt, such as a flute or a set of panpipes.  Their ears may be adorned with several earrings, and their fingers with rings collected from different regions.",
  "personality": "Lark is a restless soul, always seeking new experiences and stories to tell.  They have a deep love for travel and a thirst for knowledge about the world and its diverse cultures. Music is Lark's lifeblood, and they possess a natural talent for playing instruments and composing songs. Their performances are often infused with a touch of magic, reflecting the emotions and tales woven into their music. Lark is a gifted storyteller with a knack for captivating their audience.  They can easily make friends wherever they go and have a talent for bringing people together. Through their travels, Lark has developed a keen understanding of human nature and the interconnectedness of the world. They can offer unique perspectives and hidden truths through their songs and stories.",
  "roleInGame": "Lark wanders the realm, sharing their music and stories with the villages and towns they pass through. Players might encounter them performing in taverns, market squares, or even around a campfire in the wilderness. Lark's travels may lead them to uncover secrets or discover places of interest. They could offer quests to the player that involve retrieving a lost instrument, composing a song for a specific purpose, or helping a community in need. Lark's songs and tales offer glimpses into the broader world beyond the player's immediate surroundings. They may share news of distant lands, historical events, or even rumors of mythical creatures and hidden treasures. Lark's free spirit and optimistic outlook can offer encouragement and a fresh perspective to the player.  Their music might even have magical qualities, providing buffs or enhancing abilities."
}
</model>
''';

Content createPrompt(
    String description, String personality, String role, String background) {
  return Content.multi([
    TextPart('Write a side character design in a role-playing game set in a '
        'fantasy realm. Examples:'),
    TextPart(example1),
    TextPart(example2),
    TextPart('Only return valid JSON adhering to the following schema:'),
    TextPart(outputSchema),
    TextPart('Generate a new character with the following '
        'description: "$description", '
        'personality: "$personality", '
        'role: "$role", and '
        'background: "$background".'),
  ]);
}

const outputSchema = '''
{
  "name": String,
  "appearance": {
    "age":  String,
    "height": String,
    "weight": String,
    "build": String
    "hair": String,
    "eyes": String
  },
  "clothing": String,
  "accessories": String,
  "personality": String
  "roleInGame": String
}
''';

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
