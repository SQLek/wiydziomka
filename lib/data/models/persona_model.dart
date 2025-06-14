import 'package:equatable/equatable.dart';
import 'package:pocketbase/pocketbase.dart';

class PersonaModel extends Equatable {
  final String id;
  final String name;
  final String avatar;
  final String systemPrompt;

  const PersonaModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.systemPrompt,
  });

  factory PersonaModel.fromRecord(RecordModel record, String avatarUrl) {
    return PersonaModel(
      id: record.get<String>('id'),
      name: record.get<String>('name'),
      avatar: avatarUrl,
      systemPrompt: record.get<String>('systemPrompt'),
    );
  }

  @override
  List<Object?> get props => [id, name, avatar, systemPrompt];
}