import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_task/common_widgets/show_alert_dialog.dart';
import 'package:flutter_task/home_page.dart';
import 'package:flutter_task/services/auth.dart';
import 'package:ping_discover_network/ping_discover_network.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key key, @required this.auth}) : super(key: key);
  final AuthBase auth;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String input = '';

  Node selectedUser;
  List<Node> devices = [];

  void getDevices() {
    const port = 80;
    final stream = NetworkAnalyzer.discover2(
      '192.168.1',
      port,
      timeout: Duration(milliseconds: 5000),
    );
    int index = 0;
    stream.listen((NetworkAddress address) {
      if (address.exists) {
        index++;
        Node node = Node('Device $index', Icon(Icons.devices));
        devices.add(node);
      }
    });
  }

  @override
  void initState() {
    getDevices();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getSettings(widget.auth),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('Settings'),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                    initialValue: input,
                    decoration: InputDecoration(
                      hintText: 'URL',
                      labelText: 'Enter Url To display in view page',
                    ),
                    autocorrect: true,
                    enableSuggestions: true,
                    onChanged: (value) => input = value),
              ),
              SizedBox(height: 16.0),
              RaisedButton(
                child: Text('Save'),
                color: Colors.orange,
                onPressed: () {
                  _setSettings(widget.auth);
                  Navigator.of(context).pushNamed(HomePage.routeName);
                },
              ),
              SizedBox(height: 16.0),
              DropdownButton<Node>(
                hint: Text("Select item"),
                value: selectedUser,
                onChanged: (Node value) {
                  setState(() {
                    selectedUser = value;
                  });
                },
                items: devices.map((Node node) {
                  return DropdownMenuItem<Node>(
                    value: node,
                    child: Row(
                      children: <Widget>[
                        node.icon,
                        SizedBox(width: 10),
                        Text(node.name, style: TextStyle(color: Colors.black)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _setSettings(AuthBase auth) async {
    try {
      Map<String, dynamic> data = {
        'url': input,
      };
      await auth.setSettings(auth.currentUser.uid, data);
    } on FirebaseException catch (e) {
      showAlertDialog(
        context,
        title: e.code,
        content: e.message,
        cancelActionText: 'Cancel',
        defaultActionText: 'OK',
      );
    }
  }

  Future<void> _getSettings(AuthBase auth) async {
    try {
      var docs = await auth.getSettings(auth.currentUser.uid);
      input = docs['url'];
    } on FirebaseException catch (e) {
      showAlertDialog(
        context,
        title: e.code,
        content: e.message,
        cancelActionText: 'Cancel',
        defaultActionText: 'OK',
      );
    }
  }
}

class Node {
  const Node(this.name, this.icon);

  final String name;
  final Icon icon;
}
