import 'package:test/test.dart';
import 'package:adventofcode_2022/day12.dart';

void main() {
  test('day12 ...', () async {
    var testData1 = '''
Sabqponm
abcryxxl
accszExk
acctuvwj
abdefghi
''';

    expect(Day12().solve(Day12.parseData(testData1)), equals(31));
    expect(Day12().solve(Day12.parseData(testData1), part2: true), equals(29));
  });
}
