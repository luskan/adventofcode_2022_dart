import 'package:test/test.dart';
import 'package:adventofcode_2022/day09.dart';

void main() {
  test('day09 ...', () async {
    var testData1 = '''
R 4
U 4
L 3
D 1
R 4
D 1
L 5
R 2
''';

    expect(Day09().solve(Day09.parseData(testData1)), equals(13));
    expect(Day09().solve(Day09.parseData(testData1), part2: true), equals(1));
  });
}
