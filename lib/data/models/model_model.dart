import 'package:equatable/equatable.dart';
import 'package:pocketbase/pocketbase.dart';

class ModelModel extends Equatable {
  final String id;
  final String name;
  final bool isPreferred;
  final bool isThinking;

  const ModelModel({
    required this.id,
    required this.name,
    required this.isPreferred,
    required this.isThinking,
  });

  factory ModelModel.fromRecord(RecordModel record) {
    return ModelModel(
      id: record.get<String>('id'),
      name: record.get<String>('name'),
      isPreferred: record.get<bool>('isPreferred'),
      isThinking: record.get<bool>('isThinking'),
    );
  }

  @override
  List<Object?> get props => [id, name, isPreferred, isThinking];
}
