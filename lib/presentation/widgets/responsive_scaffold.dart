import 'package:flutter/material.dart';

class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? drawerContent;

  const ResponsiveScaffold({
    Key? key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.drawerContent,
  }) : super(key: key);

  bool _isDesktopOrTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 800; // Adjust threshold as needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      drawer: _isDesktopOrTablet(context) && drawerContent != null
          ? Drawer(child: drawerContent)
          : null,
    );
  }
}
