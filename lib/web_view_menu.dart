import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:clipboard/clipboard.dart';

enum _MenuOptions {
  otherBrowser,
  share,
  copyUrl,
}

class WebViewMenu extends StatelessWidget {
  const WebViewMenu({required this.controller, Key? key}) : super(key: key);

  final Completer<WebViewController> controller;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: controller.future,
      builder: (context, controller) {
        return PopupMenuButton<_MenuOptions>(
          onSelected: (value) async {
            switch (value) {
              case _MenuOptions.otherBrowser:
                var url = await controller.data!.currentUrl();
                debugPrint("--------- URL ---------");
                debugPrint(url);
                launchUrl(
                  Uri.parse(url!),
                  mode: LaunchMode.externalApplication,
                );
                break;
              case _MenuOptions.share:
                var url = await controller.data!.currentUrl();
                Share.share(url!);
                break;
              case _MenuOptions.copyUrl:
                var url = await controller.data!.currentUrl();
                FlutterClipboard.copy(url!).then(( value ) => {
                ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('クリップボードにコピーしました。')),
                )
                });
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.otherBrowser,
              // child: Text("ブラウザで開く"),
              child: ListTile(
                leading: Icon(Icons.launch),
                title: Text("ブラウザで開く"),
              ),
            ),
            PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.share,
              child: ListTile(
                leading: Icon(Icons.share),
                title: Text("共有"),
              ),
            ),
            PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.copyUrl,
              child: ListTile(
                leading: Icon(Icons.copy),
                title: Text("URLをコピー"),
              ),
            ),
          ],
        );

      },
    );
  }
}