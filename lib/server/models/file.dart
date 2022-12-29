import 'package:pocketbase/pocketbase.dart';

class PocketBaseFile {
  final String _id;
  final String _collectionId;
  final String _fileName;

  PocketBaseFile({
    required String id,
    required String collectionId,
    required String fileName,
  })  : _id = id,
        _collectionId = collectionId,
        _fileName = fileName;

  PocketBaseFile.fromRecordModel(RecordModel model, String fieldName)
      : this(
          id: model.id,
          collectionId: model.collectionId,
          fileName: model.data[fieldName],
        );

  String? get path => 'api/files/$_collectionId/$_id/$_fileName';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PocketBaseFile &&
          runtimeType == other.runtimeType &&
          _id == other._id &&
          _collectionId == other._collectionId &&
          _fileName == other._fileName;

  @override
  int get hashCode =>
      _id.hashCode ^ _collectionId.hashCode ^ _fileName.hashCode;
}
