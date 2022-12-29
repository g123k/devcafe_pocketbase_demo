import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:pocketbase_flutter/server/models/user.dart';
import 'package:pocketbase_flutter/server/utils.dart';
import 'package:rxdart/rxdart.dart';

export 'models/file.dart';
export 'models/user.dart';

class PocketBaseConnector {
  // Singleton
  static final PocketBaseConnector _singleton = PocketBaseConnector._internal();

  factory PocketBaseConnector() {
    return _singleton;
  }

  final PocketBase _pocketBase;
  final BehaviorSubject<User?> _connectedUser = BehaviorSubject<User?>();

  PocketBaseConnector._internal()
      : _pocketBase = PocketBase(
          'http://${Platform.isAndroid ? '10.0.2.2' : '127.0.0.1'}:8090/',
          lang: 'fr_FR',
        );

  bool isLoggedIn() {
    return _connectedUser.valueOrNull != null;
  }

  Future<User?> loginWithEmail(String email, String password) async {
    try {
      await _pocketBase
          .collection('users')
          .authWithPassword(email, password)
          .then((value) => value.token.isNotEmpty);

      _connectedUser.add(await findUser(email));

      return _connectedUser.value;
    } catch (err) {
      return null;
    }
  }

  Future<User?> loginWithUserName(String userName, String password) async {
    return loginWithEmail(userName, password);
  }

  void logOut() {
    _pocketBase.authStore.clear();
    _connectedUser.add(null);
  }

  Stream<User?> listenToUserChanges() {
    return _connectedUser.stream;
  }

  User? getConnectedUser() {
    return _connectedUser.valueOrNull;
  }

  Future<String> createUser(String email, String password) {
    assert(email.isNotEmpty);
    assert(password.isNotEmpty);

    return _pocketBase.collection('users').create(body: {
      'email': email,
      'password': password,
    }).then((value) => value.id);
  }

  Future<User?> findUser(String emailOrUsername) {
    assert(emailOrUsername.isNotEmpty);

    return _pocketBase
        .collection('users')
        .getFirstListItem(
          emailOrUsername.contains('@')
              ? 'email="$emailOrUsername"'
              : 'username="$emailOrUsername"',
        )
        .then(
          (value) => User.fromJSON(value.id, value.collectionId, value.data),
        );
  }

  Future<RecordModel> createEntry(
    String collectionId,
    Map<String, dynamic> body, {
    Iterable<PlatformFile>? files,
  }) async {
    List<MultipartFile> multipartFiles = [];

    if (files != null) {
      for (final file in files) {
        multipartFiles.add(
          MultipartFile.fromBytes(
            'file',
            await File(file.path!).readAsBytes(),
            filename: file.name,
          ),
        );
      }
    }

    return _pocketBase.collection(collectionId).create(
          body: body,
          files: multipartFiles,
        );
  }

  Future<void> removeEntry(
    String collectionId,
    String entryId,
  ) {
    return _pocketBase.collection(collectionId).delete(entryId);
  }

  Future<List<RecordModel>> getCollectionData(String collectionId) {
    return _pocketBase
        .collection(collectionId)
        .getList()
        .then((value) => value.items);
  }

  Stream<List<RecordModel>> getCollectionDataListener(String collectionId) {
    PublishSubject<List<RecordModel>> subject =
        PublishSubject<List<RecordModel>>();

    StreamSubscription<RecordSubscriptionEvent> subscription =
        listenToCollectionEvents(collectionId).listen((event) async {
      subject.add(await getCollectionData(collectionId));
    });

    subject.onCancel = () {
      print('on cancel');
      subscription.cancel();
    };
    subject.onListen = () async => subject.add(
          await getCollectionData(collectionId),
        );
    return subject.stream;
  }

  Stream<RecordSubscriptionEvent> listenToCollectionEvents(
      String collectionId) {
    return _pocketBase.collection(collectionId).listen();
  }

  String get serverUrl => _pocketBase.baseUrl;
}
