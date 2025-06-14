import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyidziomka/data/models/persona_model.dart';
import 'package:wyidziomka/data/models/model_model.dart';
import 'package:wyidziomka/data/models/chat_model.dart';
import 'package:wyidziomka/data/services/pocketbase_service.dart';
import 'package:wyidziomka/presentation/widgets/persona_icon.dart';

class PersonaSelector extends StatefulWidget {
  const PersonaSelector({super.key});

  @override
  State<PersonaSelector> createState() => PersonaSelectorState();
}

class PersonaSelectorState extends State<PersonaSelector> {
  List<PersonaModel> _personas = [];
  List<ModelModel> _preferredModels = [];
  List<ModelModel> _thinkingModels = [];
  bool _loading = true;
  int? _selectedPreferredIndex;
  int? _selectedThinkingIndex;
  int _selectedPersonaIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPersonas();
    _loadModels();
  }

  Future<void> _loadPersonas() async {
    try {
      final pbService = Provider.of<PocketBaseService>(context, listen: false);
      final result = await pbService.getPersonas();
      setState(() {
        _personas = result;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _loadModels() async {
    try {
      final pbService = Provider.of<PocketBaseService>(context, listen: false);
      final preferred = await pbService.getModels(isPreferred: true);
      final thinking = await pbService.getModels(isThinking: true);
      setState(() {
        _preferredModels = preferred;
        _thinkingModels = thinking;
        _selectedPreferredIndex = preferred.length == 1 ? 0 : null;
        _selectedThinkingIndex = thinking.length == 1 ? 0 : null;
      });
    } catch (e) {
      setState(() {
        _preferredModels = [];
        _thinkingModels = [];
      });
    }
  }

  Widget _buildModelDropdown(
    List<ModelModel> models,
    int? selectedIndex,
    void Function(int?) onChanged,
    String hint,
  ) {
    if (models.isEmpty) {
      return Text('no models avaliable - check pocketbase');
    }
    if (models.length == 1) {
      return DropdownButton<int>(
        value: 0,
        items: [DropdownMenuItem<int>(value: 0, child: Text(models[0].name))],
        onChanged: null,
      );
    }
    return DropdownButton<int>(
      value: selectedIndex,
      hint: Text(hint),
      items: List.generate(
        models.length,
        (i) => DropdownMenuItem<int>(value: i, child: Text(models[i].name)),
      ),
      onChanged: onChanged,
    );
  }

  Future<ChatModel> createChat() async {
    if (_personas.isEmpty || _selectedPersonaIndex >= _personas.length) {
      throw Exception('Invalid state');
    }
    final persona = _personas[_selectedPersonaIndex];
    String? preferredModelId;
    String? thinkingModelId;
    if (_preferredModels.isNotEmpty && _selectedPreferredIndex != null) {
      preferredModelId = _preferredModels[_selectedPreferredIndex!].id;
    }
    if (_thinkingModels.isNotEmpty && _selectedThinkingIndex != null) {
      thinkingModelId = _thinkingModels[_selectedThinkingIndex!].id;
    }

    final pbService = Provider.of<PocketBaseService>(context, listen: false);
    final chat = await pbService.createChat(
      personaId: persona.id,
      preferredModelId: preferredModelId,
      thinkingModelId: thinkingModelId,
    );

    // here use persona.systemPrompt and create initial message
    await pbService.createMessage(
      text: persona.systemPrompt,
      role: 'system',
      chatId: chat.id,
      isThinking: false,
    );

    return chat;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_personas.isEmpty) {
      return const Center(child: Text('No personas found'));
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_personas.length, (i) {
              final persona = _personas[i];
              return PersonaIcon(
                persona: persona,
                selected: i == _selectedPersonaIndex,
                onTap: () => setState(() => _selectedPersonaIndex = i),
              );
            }),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildModelDropdown(
                _preferredModels,
                _selectedPreferredIndex,
                (i) => setState(() => _selectedPreferredIndex = i),
                'Select preferred model',
              ),
              const SizedBox(width: 16),
              _buildModelDropdown(
                _thinkingModels,
                _selectedThinkingIndex,
                (i) => setState(() => _selectedThinkingIndex = i),
                'Select thinking model',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
