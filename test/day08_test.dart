import 'package:test/test.dart';
import 'package:adventofcode_2022/day08.dart';

void main() {
  test('day08 ...', () async {
    var testData1 = '''
30373
25512
65332
33549
35390
''';

    expect(Day08().solve(Day08.parseData(testData1)), equals(21));
    expect(Day08().solve(Day08.parseData(testData1), part2: true), equals(8));
  });
}
