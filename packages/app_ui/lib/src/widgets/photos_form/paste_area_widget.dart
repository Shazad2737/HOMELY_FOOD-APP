import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:app_ui/src/widgets/photos_form/photos_form.dart';
import 'package:flutter/material.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path_provider/path_provider.dart';

class PasteAreaWidget extends StatefulWidget {
  const PasteAreaWidget({required this.onImagePasted, super.key});

  final void Function(XFile image) onImagePasted;

  @override
  State<PasteAreaWidget> createState() => _PasteAreaWidgetState();
}

class _PasteAreaWidgetState extends State<PasteAreaWidget> {
  String clipboardImageError = '';
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () async {
        final of = Navigator.of(context);
        final imageBytes = await Pasteboard.image;
        if (imageBytes == null) {
          setState(() {
            clipboardImageError = 'No image found on clipboard';
          });
          return;
        }
        final tempDir = await getTemporaryDirectory();
        final file = await File(
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png',
        ).create();
        file.writeAsBytesSync(imageBytes);
        // setState(() {
        //   // images.add(XFile(file.path));
        //   // widget.onImageListChanged(images);
        // });
        widget.onImagePasted(
          XFile(file.path),
        );
        of.pop();
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        height: 200,
        // width: 100,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 30,
              ),
              SizedBox(height: 16),
              // if (clipboardImageError.isNotEmpty)
              //   Text(
              //     clipboardImageError,
              //     style: const TextStyle(
              //       color: Colors.red,
              //     ),
              //   )
              // else
              //   const Text(
              //     'Press and hold to paste from '
              //     'clipboard',
              //     textAlign: TextAlign.center,
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
