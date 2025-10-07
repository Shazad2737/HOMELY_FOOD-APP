import 'dart:io';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:app_ui/app_ui.dart';
import 'package:app_ui/src/widgets/photos_form/view_image_page.dart';
import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Page to crop an image.
///
/// The image is shown in a [CropImage] widget that allows the user to crop it.
///
/// If the user tries to save the image, the image will be cropped and saved
/// and the page will be popped with the image as the result.
///
/// If the user tries to discard the image, a dialog will be shown to confirm
/// the action and the file will be deleted.
class CropImagePage extends StatefulWidget {
  const CropImagePage({
    required this.image,
    super.key,
  });

  final XFile image;

  /// Returns a [Route] to show the [CropImagePage] with the given [image].
  static Route<XFile?> route({
    required XFile image,
  }) {
    return PageRouteBuilder<XFile?>(
      pageBuilder: (context, animation, secondaryAnimation) {
        return CropImagePage(
          image: image,
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (animation.status == AnimationStatus.reverse) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        }

        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      // builder: (context) {
      //   return CropImagePage(
      //     image: image,
      //   );
      // },
    );
  }

  @override
  State<CropImagePage> createState() => _CropImagePageState();
}

class _CropImagePageState extends State<CropImagePage> {
  // final CropController _controller = CropController();

  final CropController _controller = CropController();

  // @override
  // void initState() {
  //   super.initState();
  //   _controller = CropController();
  // }

  /// Shows a dialog to confirm the action of discarding the image.
  /// If the user confirms, the image will be deleted and the page will be
  /// popped.
  void discardChanges(
    BuildContext context,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Are you sure you discard the changes?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.black,
                ),
          ),
          content: Text(
            'This will discard all changes made to the image.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.black,
                ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // pop the dialog
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
                Navigator.of(context).popUntil(
                  (route) => route.settings.name == ViewImagePage.routeName,
                );
                // try {
                //   await image.delete();
                // } on Exception catch (e, s) {
                //   Logger.logError('Error deleting image: ', e,
                //stackTrace: s);
                // }
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
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: _controller.rotateLeft,
                    child: const Icon(
                      Icons.rotate_left,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _controller.rotateRight,
                    child: const Icon(
                      Icons.rotate_right,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
              const Space(),
              Expanded(
                child: Hero(
                  tag: widget.image.path,
                  child: CropImage(
                    controller: _controller,
                    image: Image.file(File(widget.image.path)),
                  ),
                ),
              ),
              const Space(),
              Row(
                children: [
                  ElevatedButton(
                    // style: IconButton.styleFrom(
                    //   backgroundColor: AppColors.base100.withOpacity(0.5),
                    // ),
                    child: Text(
                      'Cancel',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    onPressed: () {
                      discardChanges(context);
                    },
                  ),
                  const Spacer(),
                  ElevatedButton(
                    // style: IconButton.styleFrom(
                    //   backgroundColor: AppColors.greenLight,
                    // ),
                    onPressed: () {
                      print('pressed');
                      _onSaveButtonPressed(context);
                    },
                    child: Text(
                      'Done',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSaveButtonPressed(BuildContext context) async {
    final nav = Navigator.of(context);
    final watch = Stopwatch()..start();
    print('finding length');
    final beforeLength = await widget.image.length();
    watch.stop();
    print('time taken: ${watch.elapsedMilliseconds}');
    print('before $beforeLength');
    watch
      ..reset()
      ..start();
    final cropedImage = await _controller.croppedBitmap();
    print(
      'cropped, converting to file, time taken: ${watch.elapsedMilliseconds}',
    );
    watch
      ..reset()
      ..start();
    final image = await cropedImage.toXFile();
    print(
      'after ${await image.length()}, time taken: ${watch.elapsedMilliseconds}',
    );
    nav.pop(image);
    // });
  }
}

extension on ui.Image {
  Future<XFile> toXFile() async {
    /// create a anew file in the temp directory
    /// and write the image to it
    print('getting temp dir');
    final tempDir = await getTemporaryDirectory();
    print('creating file');
    final file = await File(
      '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png',
    ).create();
    print('writing to file');
    final byteData = await toByteData(format: ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();
    print('writing to file 2');
    await file.writeAsBytes(buffer);
    return XFile(file.path);
  }
}
