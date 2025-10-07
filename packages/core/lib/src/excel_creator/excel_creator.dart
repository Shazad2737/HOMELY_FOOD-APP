// import 'dart:typed_data';

// import 'package:excel/excel.dart';
// import 'package:flutter_file_dialog/flutter_file_dialog.dart';

// export 'report_generator.dart';

// /// Convenience class for creating Excel files.
// class ExcelCreator {
//   /// Creates an Excel file with given data.
//   Future<void> create({
//     required List<ExcelSheetRow> data,
//     ExcelSheetRow? title,
//   }) async {
//     // automatically creates 1 empty sheet: Sheet1
//     final excel = Excel.createExcel();

//     final sheet = excel['Sheet1'];

//     final cellStyle = CellStyle(
//       backgroundColorHex: ExcelColor.white,
//       fontFamily: getFontFamily(FontFamily.Calibri),
//     )..underline = Underline.Single;

//     // title?.forEach((cell) {
//     //   sheet.cell(CellIndex.indexByString(cell.column + cell.row.toString()))
//     //     ..value = cell.value
//     //     ..cellStyle = cellStyle.copyWith(
//     //       boldVal: true,
//     //     );
//     // });

//     title?.cells.forEach((cell) {
//       sheet.cell(CellIndex.indexByString('${cell.column}1'))
//         ..value = cell.value
//         ..cellStyle = cellStyle.copyWith(
//           boldVal: true,
//         );
//     });

//     for (final row in data) {
//       for (final cell in row.cells) {
//         sheet.cell(
//           CellIndex.indexByString(
//             cell.column + cell.row.toString(),
//           ),
//         )
//           ..value = cell.value
//           ..cellStyle = cellStyle;
//       }
//     }
//     final fileBytes = excel.save();
//     // final directory = Platform.isAndroid
//     //     ? await getExternalStorageDirectory()
//     //     : await getApplicationDocumentsDirectory();

//     // print(directory?.path);

//     if (!await FlutterFileDialog.isPickDirectorySupported()) {
//       print('Picking directory not supported');
//       return;
//     }

//     final pickedDirectory = await FlutterFileDialog.pickDirectory();

//     if (pickedDirectory != null) {
//       final filePath = await FlutterFileDialog.saveFileToDirectory(
//         directory: pickedDirectory,
//         data: Uint8List.fromList(fileBytes!),
//         fileName: 'example.xlsx',
//         mimeType:
//             'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
//         replace: true,
//       );

//       print('File saved to: $filePath');
//     }
//     // File('${directory?.path}/example.xlsx')
//     //   ..createSync(recursive: true)
//     //   ..writeAsBytesSync(fileBytes!);
//   }

//   /// Returns a [CellValue] object based on the type of the value.
//   /// Can be a string, int, double, or bool.
//   static CellValue getCellValue(dynamic value) {
//     if (value is String) {
//       return TextCellValue(value);
//     } else if (value is int) {
//       return IntCellValue(value);
//     } else if (value is double) {
//       return DoubleCellValue(value);
//     } else if (value is bool) {
//       return BoolCellValue(value);
//     } else if (value == null) {
//       return TextCellValue('');
//     } else if (value is DateTime) {
//       return DateTimeCellValue.fromDateTime(value);
//     } else {
//       return TextCellValue(value.toString());
//     }
//   }
// }

// /// Represents a cell in an Excel sheet.
// class Cell {
//   Cell({
//     required this.column,
//     required this.row,
//     dynamic value,
//   }) : value = ExcelCreator.getCellValue(value);

//   /// The column of the cell.
//   /// Usually a letter, e.g. 'A', 'B', 'C', etc.
//   final String column;

//   /// The row of the cell.
//   /// Starts from 1.
//   final int row;

//   /// The value of the cell.
//   /// Can be a string, int, double, or bool.
//   final CellValue value;
// }

// /// Represents a row in an Excel sheet.
// class ExcelSheetRow {
//   /// Creates a row with given cell values and row number.
//   ExcelSheetRow.fromValues({
//     required List<dynamic> cellValues,
//     required int row,
//   }) : cells = List<Cell>.generate(
//           cellValues.length,
//           (index) => Cell(
//             column: String.fromCharCode(65 + index),
//             row: row,
//             value: cellValues[index],
//           ),
//         );

//   /// The cells in the row.
//   final List<Cell> cells;
// }
