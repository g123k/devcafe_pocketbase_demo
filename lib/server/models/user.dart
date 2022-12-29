import 'package:pocketbase_flutter/server/models/file.dart';

class User {
  final String id;
  final String? username;
  final String? email;
  final String? name;
  final PocketBaseFile? avatar;
  final DateTime? created;
  final DateTime? updated;

  User.fromJSON(this.id, String collectionId, Map<dynamic, dynamic> json)
      : username = json['username'],
        email = json['email'],
        name = json['name'],
        avatar = json['avatar'] != null
            ? PocketBaseFile(
                id: id, collectionId: collectionId, fileName: json['avatar'])
            : null,
        created =
            json['created'] != null ? DateTime.parse(json['created']) : null,
        updated =
            json['updated'] != null ? DateTime.parse(json['updated']) : null;
}
