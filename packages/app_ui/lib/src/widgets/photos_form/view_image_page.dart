import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:app_ui/src/widgets/photos_form/crop_image_page.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

/// Page to view an image in full screen.
///
/// Also gives the option to edit the image or discard it.
/// If the user tries to discard the image, a dialog will be shown to confirm
/// the action and the file will be deleted.
///
/// If the user tries to edit the image, the image will be opened in the editor.
///
/// If the user tries to save the image, the image will be saved and the page
/// will be popped with the image as the result.
class ViewImagePage extends StatefulWidget {
  const ViewImagePage({
    required this.image,
    super.key,
  });

  final XFile image;

  static const String routeName = '/view-image';

  /// Route to show the [ViewImagePage] with the given [image].
  static Route<XFile?> route({
    required XFile image,
  }) {
    return PageRouteBuilder<XFile?>(
      pageBuilder: (context, animation, secondaryAnimation) => ViewImagePage(
        image: image,
      ),
      settings: const RouteSettings(name: routeName),
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0, 1);
        const end = Offset.zero;
        // const begin = 0.0;
        // const end = 1.0;
        const curve = Curves.easeInOut;

        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  State<ViewImagePage> createState() => _ViewImagePageState();
}

class _ViewImagePageState extends State<ViewImagePage> {
  void _onEditButtonPressed(BuildContext context) {
    final nav = Navigator.of(context);
    nav
        .push(
      CropImagePage.route(
        image: _image,
      ),
    )
        .then((value) {
      if (value != null) {
        setState(() {
          _image = value;
        });
      }
    });
    // .then(nav.pop);
  }

  late XFile _image;

  @override
  void initState() {
    super.initState();
    _image = widget.image;
  }

  /// Shows a dialog to confirm the action of discarding the image.
  /// If the user confirms, the image will be deleted and the page will be
  /// popped.
  void showDiscardImageDialog(BuildContext context, XFile image) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Are you sure you want discard this image?'),
          content: const Text(
            'You may have to take the photo again. '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                    ),
              ),
            ),
            TextButton(
              onPressed: () async {
                // final navigator = Navigator.of(context);
                try {
                  // await _image.delete().then((value) {
                  //   print('Image deleted, $value');
                  //   navigator
                  //     ..pop()
                  //     ..pop();
                  // });

                  // navigator
                  //   ..pop()
                  //   ..pop();
                } on Exception catch (e, s) {
                  Logger.logError('Error deleting image: ', e, stackTrace: s);
                }
              },
              child: Text(
                'Discard',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.error,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onPanUpdate: print,
          onVerticalDragUpdate: (details) {
            if (details.primaryDelta! > 20) {
              // _showCancelDialog(context);
              showDiscardImageDialog(context, widget.image);
            }
          },
          child: Stack(
            children: [
              PhotoView(
                imageProvider: FileImage(File(_image.path)),
                heroAttributes: PhotoViewHeroAttributes(tag: _image.path),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.textPrimary.withOpacity(0.5),
                  ),
                  icon: const Icon(
                    Icons.delete_forever,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // _showCancelDialog(context);
                    showDiscardImageDialog(context, widget.image);
                  },
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.textPrimary.withOpacity(0.5),
                  ),
                  icon: const Icon(
                    Icons.crop,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    _onEditButtonPressed(context);
                  },
                ),
              ),
              Positioned(
                bottom: 0,
                // left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(_image);
                    },
                    icon: const Icon(
                      Icons.done_outlined,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
