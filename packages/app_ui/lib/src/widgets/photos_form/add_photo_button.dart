import 'package:flutter/material.dart';

class AddPhotoButton extends StatelessWidget {
  const AddPhotoButton({
    required this.isLoading,
    super.key,
  });

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    // const buttonWidth = 100.0;
    const grey = Colors.grey;

    return Container(
      decoration: BoxDecoration(
        // color: AppColors.greyMedium,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: grey,
          width: 3,
        ),
      ),
      child: isLoading
          ? const Center(
              child: SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(
                  color: grey,
                  strokeWidth: 5,
                ),
              ),
            )
          : const Icon(
              Icons.add,
              color: grey,
              size: 80,
            ),
    );
  }
}
