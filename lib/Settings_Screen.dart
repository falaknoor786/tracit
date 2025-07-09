import 'package:flutter/cupertino.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _UsersState();
}

class _UsersState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text("comming Soon"),
      ),
    );
  }
}
