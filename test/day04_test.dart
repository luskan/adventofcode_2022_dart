import 'package:test/test.dart';
import 'package:adventofcode_2022/day04.dart';

void main() {
  test('day04 ...', () async {
    var testData1 = '''
2-4,6-8
2-3,4-5
5-7,7-9
2-8,3-7
6-6,4-6
2-6,4-8
''';
    expect(Day04().solve(Day04.parseData(testData1)), equals(2));
    expect(Day04().solve(Day04.parseData(testData1), part2: true), equals(4));
  });
}
