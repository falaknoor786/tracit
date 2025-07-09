import 'package:flutter/material.dart';

class Inv extends StatefulWidget {
  const Inv({super.key});

  @override
  State<Inv> createState() => _InvState();
}

class _InvState extends State<Inv> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text("Data Wise"),
        ),
      ),
    );
  }
}
