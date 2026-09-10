import 'package:flutter/material.dart';
import 'adhkar_screen.dart';

class AdhkarTabScreen extends StatelessWidget {
  final String initialType;
  const AdhkarTabScreen({super.key, this.initialType = 'morning'});

  @override
  Widget build(BuildContext context) {
    return AdhkarScreen(initialType: initialType);
  }
}