import 'package:test/test.dart';
import 'package:adventofcode_2022/day02.dart';

void main() {
  test('day02 ...', () async {
    var testData1 = '''
A Y
B X
C Z
''';
    expect(Day02().solve(Day02.parseData(testData1)), equals(15));
    expect(Day02().solve(Day02.parseData(testData1), part2: true), equals(12));
  });
}
