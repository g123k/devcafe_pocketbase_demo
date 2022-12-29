import 'dart:async';

import 'package:pocketbase/pocketbase.dart';

extension CollectionExtension on RecordService {
  Stream<RecordSubscriptionEvent> listen() {
    StreamController<RecordSubscriptionEvent> controller =
        StreamController<RecordSubscriptionEvent>();

    subscribe('*', (RecordSubscriptionEvent e) {
      controller.add(e);
    }).then((value) => controller.onCancel = () => value());

    return controller.stream;
  }
}
