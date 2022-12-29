import 'package:flutter/material.dart';
import 'package:pocketbase_flutter/server/models/user.dart';
import 'package:pocketbase_flutter/server/pocketbase.dart';
import 'package:pocketbase_flutter/ui/pocketbase_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PocketBase Demo'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: PocketBaseUserListener(
          connectedChild: PocketBaseLoggedIn(
            collectionName: 'posts',
          ),
          disconnectedChild: PocketBaseLoggedOut(),
        ),
      ),
    );
  }
}

class PocketBaseUserListener extends StatelessWidget {
  final Widget connectedChild;
  final Widget disconnectedChild;

  const PocketBaseUserListener({
    required this.connectedChild,
    required this.disconnectedChild,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: PocketBaseConnector().listenToUserChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.hasData) {
            return connectedChild;
          } else {
            return disconnectedChild;
          }
        });
  }
}

class PocketBaseLoggedOut extends StatelessWidget {
  const PocketBaseLoggedOut({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PocketBaseConnector connector = PocketBaseConnector();

    return Center(
      child: OutlinedButton(
        onPressed: () => connector.loginWithUserName('g123k', '12345678'),
        child: const Text('Se connecter'),
      ),
    );
  }
}

class PocketBaseLoggedIn extends StatelessWidget {
  final String collectionName;

  const PocketBaseLoggedIn({
    required this.collectionName,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Expanded(child: ConnectedUser()),
            Spacer(),
            LogOutButton()
          ],
        ),
        const Divider(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PocketBaseCollectionEventListener(collectionName: collectionName),
              Expanded(
                child:
                    PocketBaseCollectionViewer(collectionName: collectionName),
              ),
              PocketBaseCreateEntryButton(collectionName: collectionName),
            ],
          ),
        ),
      ],
    );
  }
}

class ConnectedUser extends StatelessWidget {
  const ConnectedUser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PocketBaseConnector connector = PocketBaseConnector();
    User? user = connector.getConnectedUser();

    assert(user != null);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (user!.avatar != null) ...[
          CircleAvatar(
            child: ClipOval(
              child: AspectRatio(
                aspectRatio: 1,
                child: PocketBaseImageViewer(file: user.avatar!),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
        ],
        Expanded(
          child: Text(
            user.name ?? user.username ?? user.email ?? 'Unknown',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class LogOutButton extends StatelessWidget {
  const LogOutButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => PocketBaseConnector().logOut(),
      child: const Text('Se déconnecter'),
    );
  }
}
