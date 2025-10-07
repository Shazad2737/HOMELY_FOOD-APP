// import 'package:excel/excel.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:pdf/widgets.dart' as pw;

// class PettyCashTransaction {
//   PettyCashTransaction({
//     required this.date,
//     required this.description,
//     required this.amount,
//     required this.project,
//     required this.isIncome,
//   });
//   final DateTime date;
//   final String description;
//   final double amount;
//   final String project;
//   final bool isIncome;
// }

// class PettyCashReport {
//   PettyCashReport({
//     required this.title,
//     required this.openingBalance,
//     required this.transactions,
//   });
//   final String title;
//   final double openingBalance;
//   final List<PettyCashTransaction> transactions;

//   double get totalIncome =>
//       transactions.where((t) => t.isIncome).fold(0, (sum, t) => sum + t.amount);
//   double get totalExpenses => transactions
//       .where((t) => !t.isIncome)
//       .fold(0, (sum, t) => sum + t.amount);
//   double get closingBalance => openingBalance + totalIncome - totalExpenses;
// }

// abstract class PettyCashReportRenderer {
//   Future<Uint8List> render(PettyCashReport report);
// }

// class PdfPettyCashReportRenderer implements PettyCashReportRenderer {
//   @override
//   Future<Uint8List> render(PettyCashReport report) async {
//     final pdf = pw.Document();

//     pdf.addPage(
//       pw.Page(
//         build: (pw.Context context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Text(
//                 report.title,
//                 style: pw.TextStyle(
//                   fontSize: 18,
//                   fontWeight: pw.FontWeight.bold,
//                 ),
//               ),
//               pw.SizedBox(height: 20),
//               pw.Text(
//                 'Opening Balance: ${report.openingBalance.toStringAsFixed(2)}',
//               ),
//               pw.SizedBox(height: 10),
//               _buildIncomeSection(report),
//               pw.SizedBox(height: 10),
//               _buildExpensesSection(report),
//               pw.SizedBox(height: 10),
//               pw.Text(
//                 'Closing Balance: ${report.closingBalance.toStringAsFixed(2)}',
//               ),
//             ],
//           );
//         },
//       ),
//     );

//     return pdf.save();
//   }

//   pw.Widget _buildIncomeSection(PettyCashReport report) {
//     final incomeTransactions =
//         report.transactions.where((t) => t.isIncome).toList();
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Text('Income', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//         pw.Table(
//           border: pw.TableBorder.all(),
//           children: [
//             pw.TableRow(
//               children: ['Date', 'Description', 'Amount']
//                   .map(
//                     (e) => pw.Container(
//                       alignment: pw.Alignment.center,
//                       child: pw.Text(
//                         e,
//                         style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                       ),
//                     ),
//                   )
//                   .toList(),
//             ),
//             ...incomeTransactions.map(
//               (t) => pw.TableRow(
//                 children: [
//                   pw.Text(DateFormat('dd-MM-yy').format(t.date)),
//                   pw.Text(t.description),
//                   pw.Text(t.amount.toStringAsFixed(2)),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         pw.Text('Total Income: ${report.totalIncome.toStringAsFixed(2)}'),
//       ],
//     );
//   }

//   pw.Widget _buildExpensesSection(PettyCashReport report) {
//     final expenseTransactions =
//         report.transactions.where((t) => !t.isIncome).toList();
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Text(
//           'Expenses',
//           style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//         ),
//         pw.Table(
//           border: pw.TableBorder.all(),
//           children: [
//             pw.TableRow(
//               children: ['Date', 'Description', 'Project', 'Amount']
//                   .map(
//                     (e) => pw.Container(
//                       alignment: pw.Alignment.center,
//                       child: pw.Text(
//                         e,
//                         style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                       ),
//                     ),
//                   )
//                   .toList(),
//             ),
//             ...expenseTransactions.map(
//               (t) => pw.TableRow(
//                 children: [
//                   pw.Text(DateFormat('dd-MM-yy').format(t.date)),
//                   pw.Text(t.description),
//                   pw.Text(t.project),
//                   pw.Text(t.amount.toStringAsFixed(2)),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         pw.Text('Total Expenses: ${report.totalExpenses.toStringAsFixed(2)}'),
//       ],
//     );
//   }
// }

// class ExcelPettyCashReportRenderer implements PettyCashReportRenderer {
//   @override
//   Future<Uint8List> render(PettyCashReport report) async {
//     final excel = Excel.createExcel();
//     final sheet = excel['Sheet1'];

//     // Title
//     sheet.cell(CellIndex.indexByString('A1')).value =
//         TextCellValue(report.title);

//     // Opening Balance
//     sheet.cell(CellIndex.indexByString('A3')).value =
//         TextCellValue('Opening Balance:');
//     sheet.cell(CellIndex.indexByString('B3')).value =
//         DoubleCellValue(report.openingBalance);

//     // Income Section
//     sheet.cell(CellIndex.indexByString('A5')).value = TextCellValue('Income');
//     sheet.cell(CellIndex.indexByString('A6')).value = TextCellValue('Date');
//     sheet.cell(CellIndex.indexByString('B6')).value =
//         TextCellValue('Description');
//     sheet.cell(CellIndex.indexByString('C6')).value = TextCellValue('Amount');

//     var row = 7;
//     for (final t in report.transactions.where((t) => t.isIncome)) {
//       sheet.cell(CellIndex.indexByString('A$row'))
//         ..value = DateCellValue(
//           year: t.date.year,
//           month: t.date.month,
//           day: t.date.day,
//         )
//         ..cellStyle = CellStyle(
//           fontFamily: getFontFamily(FontFamily.Calibri),
//           numberFormat: NumFormat.defaultDateTime,
//         );
//       sheet.cell(CellIndex.indexByString('B$row')).value =
//           TextCellValue(t.description);
//       sheet.cell(CellIndex.indexByString('C$row')).value =
//           DoubleCellValue(t.amount);
//       row++;
//     }

//     sheet.cell(CellIndex.indexByString('B$row')).value =
//         TextCellValue('Total Income:');
//     sheet.cell(CellIndex.indexByString('C$row')).value =
//         DoubleCellValue(report.totalIncome);

//     // Expenses Section
//     row += 2;
//     sheet.cell(CellIndex.indexByString('A$row')).value =
//         TextCellValue('Expenses');
//     row++;
//     sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue('Date');
//     sheet.cell(CellIndex.indexByString('B$row')).value =
//         TextCellValue('Description');
//     sheet.cell(CellIndex.indexByString('C$row')).value =
//         TextCellValue('Project');
//     sheet.cell(CellIndex.indexByString('D$row')).value =
//         TextCellValue('Amount');

//     row++;
//     for (final t in report.transactions.where((t) => !t.isIncome)) {
//       sheet.cell(CellIndex.indexByString('A$row'))
//         ..value = DateCellValue(
//           year: t.date.year,
//           month: t.date.month,
//           day: t.date.day,
//         )
//         ..cellStyle = CellStyle(
//           fontFamily: getFontFamily(FontFamily.Calibri),
//           numberFormat: NumFormat.defaultDateTime,
//         );
//       sheet.cell(CellIndex.indexByString('B$row')).value =
//           TextCellValue(t.description);
//       sheet.cell(CellIndex.indexByString('C$row')).value =
//           TextCellValue(t.project);
//       sheet.cell(CellIndex.indexByString('D$row')).value =
//           DoubleCellValue(t.amount);
//       row++;
//     }

//     sheet.cell(CellIndex.indexByString('C$row')).value =
//         TextCellValue('Total Expenses:');
//     sheet.cell(CellIndex.indexByString('D$row')).value =
//         DoubleCellValue(report.totalExpenses);

//     // Closing Balance
//     row += 2;
//     sheet.cell(CellIndex.indexByString('A$row')).value =
//         TextCellValue('Closing Balance:');
//     sheet.cell(CellIndex.indexByString('B$row')).value =
//         DoubleCellValue(report.closingBalance);

//     // // Apply some basic styling
//     // for (final cell in [...sheet.row(6), ...sheet.row(row - 2)]) {
//     //   cell?.cellStyle = CellStyle(
//     //     bold: true,
//     //     horizontalAlign: HorizontalAlign.Center,
//     //   );
//     // }

//     // Set column widths
//     sheet.setColumnWidth(0, 15); // Date column
//     sheet.setColumnWidth(1, 30); // Description column
//     sheet.setColumnWidth(2, 15); // Project/Amount column
//     sheet.setColumnWidth(3, 15); // Amount column (for expenses)

//     final bytes = excel.encode();

//     if (bytes == null) {
//       throw Exception('Failed to encode Excel file');
//     }

//     final uint8List = Uint8List.fromList(bytes);

//     return uint8List;

//     // return excel.encode()!;
//   }
// }

// class PettyCashReportingService {
//   Future<Uint8List> generateReport(
//     PettyCashReport report,
//     PettyCashReportRenderer renderer,
//   ) async {
//     return renderer.render(report);
//   }
// }
