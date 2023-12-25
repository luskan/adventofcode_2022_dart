import 'package:adventofcode_2022/day14.dart';
import 'package:test/test.dart';

void main() {
  test('day14 ...', () async {
    var testData1 = '''
498,4 -> 498,6 -> 496,6
503,4 -> 502,4 -> 502,9 -> 494,9
''';

    expect(Day14().solve(Day14.parseData(testData1)), equals(24));
    expect(Day14().solve(Day14.parseData(testData1), part2: true), equals(93));
  });
}
