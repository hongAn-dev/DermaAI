import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart run tools/check_braces.dart <file>');
    exit(1);
  }
  final file = File(args[0]);
  if (!file.existsSync()) {
    print('File not found: ${args[0]}');
    exit(1);
  }
  final lines = file.readAsLinesSync();
  int open = 0, paren = 0, brack = 0;
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    for (var r = 0; r < line.length; r++) {
      final c = line.codeUnitAt(r);
      if (c == '{'.codeUnitAt(0)) {
        open++;
      } else if (c == '}'.codeUnitAt(0))
        open--;
      else if (c == '('.codeUnitAt(0))
        paren++;
      else if (c == ')'.codeUnitAt(0))
        paren--;
      else if (c == '['.codeUnitAt(0))
        brack++;
      else if (c == ']'.codeUnitAt(0)) brack--;
      if (open < 0 || paren < 0 || brack < 0) {
        print('Unbalanced at line ${i + 1}: { $open } ( $paren ) [ $brack ]');
        exit(0);
      }
    }
  }
  print('Final balances at end of file: { $open } ( $paren ) [ $brack ]');
}
