import 'package:flutter_test/flutter_test.dart';
void main(){test('datas reprodutivas',(){final first=DateTime(2026,9,10);expect(first.add(const Duration(days:6)),DateTime(2026,9,16));expect(first.add(const Duration(days:14)),DateTime(2026,9,24));expect(first.add(const Duration(days:19)),DateTime(2026,9,29));expect(first.add(const Duration(days:46)),DateTime(2026,10,26));});}
