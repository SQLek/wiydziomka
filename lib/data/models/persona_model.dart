import 'package:equatable/equatable.dart';
import 'package:pocketbase/pocketbase.dart';

class PersonaModel extends Equatable {
  final String id;
  final String name;
  final String avatar;

  const PersonaModel({
    required this.id,
    required this.name,
    required this.avatar,
  });

  factory PersonaModel.fromRecord(RecordModel record, String avatarUrl) {
    return PersonaModel(
      id: record.get<String>('id'),
      name: record.get<String>('name'),
      avatar: avatarUrl,
    );
  }

  @override
  List<Object?> get props => [id, name, avatar];
}