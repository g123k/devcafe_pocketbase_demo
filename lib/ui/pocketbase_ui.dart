import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:pocketbase_flutter/server/pocketbase.dart';

class PocketBaseImageViewer extends StatelessWidget {
  final PocketBaseFile file;

  const PocketBaseImageViewer({required this.file, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      join(PocketBaseConnector().serverUrl, file.path),
    );
  }
}

class PocketBaseCollectionViewer extends StatelessWidget {
  final String collectionName;

  const PocketBaseCollectionViewer({
    required this.collectionName,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contenu :',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: StreamBuilder(
              stream: PocketBaseConnector()
                  .getCollectionDataListener(collectionName),
              builder: (BuildContext context,
                  AsyncSnapshot<List<RecordModel>> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data?.isEmpty == true) {
                    return const Text('Aucune donnée !');
                  }

                  return Scrollbar(
                    trackVisibility: true,
                    thumbVisibility: true,
                    child: ListView.builder(
                        primary: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (BuildContext context, int index) {
                          RecordModel data = snapshot.data![index];
                          String? file = data.data['file'];

                          Map<String, dynamic> dataMap = Map.from(data.data);
                          dataMap.remove('file');

                          return ListTile(
                            leading: file != null && file.isNotEmpty
                                ? PocketBaseImageViewer(
                                    file: PocketBaseFile.fromRecordModel(
                                      data,
                                      'file',
                                    ),
                                  )
                                : null,
                            title: Text(dataMap.toString()),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  PocketBaseConnector().removeEntry(
                                collectionName,
                                data.id,
                              ),
                            ),
                          );
                        }),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
        ),
      ],
    );
    ;
  }
}

class PocketBaseCollectionEventListener extends StatelessWidget {
  final String collectionName;

  const PocketBaseCollectionEventListener(
      {required this.collectionName, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dernier événement :',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          StreamBuilder<RecordSubscriptionEvent>(
              stream: PocketBaseConnector()
                  .listenToCollectionEvents(collectionName),
              builder: (BuildContext context,
                  AsyncSnapshot<RecordSubscriptionEvent> snapshot) {
                if (snapshot.hasData) {
                  return Text(
                      '${snapshot.data!.action} : ${snapshot.data!.record}');
                } else {
                  return const Text('Aucun');
                }
              }),
        ],
      ),
    );
  }
}

class PocketBaseCreateEntryButton extends StatelessWidget {
  final String collectionName;

  const PocketBaseCreateEntryButton({
    required this.collectionName,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton(
        onPressed: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: FileType.image,
          );

          PocketBaseConnector().createEntry(
              collectionName, {'title': _generateRandomString(15)},
              files: result?.files.map((e) => e).toList());
        },
        child: Text('Créer une entrée dans $collectionName'),
      ),
    );
  }

  String _generateRandomString(int len) {
    var r = Random();
    return String.fromCharCodes(
      List.generate(len, (index) => r.nextInt(33) + 89),
    );
  }
}
