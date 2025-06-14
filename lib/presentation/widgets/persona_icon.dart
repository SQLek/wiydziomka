import 'package:flutter/material.dart';
import 'package:wyidziomka/data/models/persona_model.dart';

class PersonaIcon extends StatelessWidget {
  final PersonaModel persona;
  final bool selected;
  final VoidCallback onTap;

  const PersonaIcon({
    super.key,
    required this.persona,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? Colors.deepPurple : Colors.grey,
                width: selected ? 3 : 1,
              ),
            ),
            child: persona.avatar.isNotEmpty
                ? CircleAvatar(
                    radius: selected ? 32 : 28,
                    backgroundImage: NetworkImage(persona.avatar),
                  )
                : Icon(
                    Icons.person,
                    size: selected ? 64 : 56,
                    color: selected ? Colors.deepPurple : Colors.grey,
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          persona.name,
          style: TextStyle(
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? Colors.deepPurple : Colors.grey,
          ),
        ),
      ],
    );
  }
}
