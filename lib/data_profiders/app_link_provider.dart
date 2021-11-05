import 'package:flutter/material.dart';
import 'package:spot/pages/view_video_page.dart';
import 'package:spot/utils/constants.dart';
import 'package:uni_links/uni_links.dart';

/// Takes care of app links
class AppLinkProvider {
  /// Sets up the receiver of app links
  Future<void> setupAppLinks(BuildContext context) async {
    /// Quick and dirty way of
    /// waiting until TabPage gets added to the widget tree.
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final initialUri = await getInitialUri();
      _handleAppLink(uri: initialUri, context: context);
      uriLinkStream.listen((uri) => _handleAppLink(uri: uri, context: context));
    } catch (_) {
      context.showErrorSnackbar('Error opening the video.');
    }
  }

  void _handleAppLink({required Uri? uri, required BuildContext context}) {
    if (uri != null) {
      final path = uri.path;
      if (path.split('/').first == 'post') {
        final videoId = path.split('/').last;
        Navigator.of(context).push(ViewVideoPage.route(videoId: videoId));
      }
    }
  }
}
