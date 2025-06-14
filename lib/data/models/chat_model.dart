import 'package:equatable/equatable.dart';
import 'package:pocketbase/pocketbase.dart';

class ChatModel extends Equatable {
  final String id;
  final String name;
  final String? preferredModelId;
  final String? thinkingModelId;

  const ChatModel({
    required this.id,
    required this.name,
    this.preferredModelId,
    this.thinkingModelId,
  });

  factory ChatModel.fromRecord(RecordModel record) {
    return ChatModel(
      id: record.get<String>('id'),
      name: record.get<String>('name'),
      preferredModelId: record.get<String?>('preferredModel'),
      thinkingModelId: record.get<String?>('thinkingModel'),
    );
  }

  @override
  List<Object?> get props => [id, name, preferredModelId, thinkingModelId];
}
