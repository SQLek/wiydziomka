import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyidziomka/data/models/persona_model.dart';
import 'package:wyidziomka/data/services/pocketbase_service.dart';
import 'package:wyidziomka/presentation/widgets/persona_icon.dart';

class PersonaSelector extends StatefulWidget {
  final int selectedIndex;
  final void Function(int) onSelect;

  const PersonaSelector({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  State<PersonaSelector> createState() => _PersonaSelectorState();
}

class _PersonaSelectorState extends State<PersonaSelector> {
  List<PersonaModel> _personas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPersonas();
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_personas.isEmpty) {
      return const Center(child: Text('No personas found'));
    }
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_personas.length, (i) {
          final persona = _personas[i];
          return PersonaIcon(
            persona: persona,
            selected: i == widget.selectedIndex,
            onTap: () => widget.onSelect(i),
          );
        }),
      ),
    );
  }
}
