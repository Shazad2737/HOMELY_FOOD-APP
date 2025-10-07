// import 'package:core/core.dart';

// class TransactionExcelExportHelper {
//   final ExcelCreator _excelCreator = ExcelCreator();

//   Future<void> exportTransactionsToExcel(List<Transaction> transactions) async {
//     final headers = ExcelSheetRow.fromValues(
//       cellValues: [
//         // 'ID',
//         'Date',
//         'Amount',
//         // 'Country',
//         'Description',
//         'Property',
//         'Type',
//         'Images',
//         'Unit',
//       ],
//       row: 1,
//     );

//     final rows = <ExcelSheetRow>[];
//     for (var i = 0; i < transactions.length; i++) {
//       final transaction = transactions[i];
//       final rowIndex = i + 2; // Start from row 2 because row 1 is for headers

//       final row = ExcelSheetRow.fromValues(
//         cellValues: [
//           // transaction.id,
//           // transaction.date,
//           transaction.amount,
//           // transaction.country,
//           transaction.description ?? 'N/A',
//           transaction.property?.propertyName ?? 'N/A',
//           transaction.type,
//           transaction.images.join(', '),
//           transaction.unit?.name ?? 'N/A',
//         ],
//         row: rowIndex,
//       );

//       rows.add(row);
//     }

//     await _excelCreator.create(data: rows, title: headers);
//   }
// }
