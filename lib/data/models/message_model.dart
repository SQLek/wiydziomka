import 'package:equatable/equatable.dart';
import 'package:pocketbase/pocketbase.dart';

class MessageModel extends Equatable {
  final String id;
  final String role;
  final String text;

  const MessageModel({
    required this.id,
    required this.role,
    required this.text,
  });

  factory MessageModel.fromRecord(RecordModel record) {
    return MessageModel(
      id: record.get<String>('id'),
      role: record.get<String>('role'),
      text: record.get<String>('text'),
    );
  }

  @override
  List<Object?> get props => [id, role, text];
}
