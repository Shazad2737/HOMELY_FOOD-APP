// import 'package:app_ui/app_ui.dart';
// import 'package:flutter/material.dart';

// class PatternedCard extends StatelessWidget {
//   const PatternedCard({
//     required this.child,
//     required this.width,
//     required this.height,
//     super.key,
//   });

//   final Widget child;

//   final double width;
//   final double height;

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: width,
//       height: height,
//       child: LayoutBuilder(
//         builder: (context, cons) {
//           return Stack(
//             children: [
//               appImages.balanceCard.svg(
//                 width: cons.maxWidth,
//                 height: cons.maxHeight,
//                 fit: BoxFit.fill,
//               ),
//               child,
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
