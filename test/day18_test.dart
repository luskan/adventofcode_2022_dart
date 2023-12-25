import 'package:adventofcode_2022/day18.dart';
import 'package:test/test.dart';

void main() {
  test('day18 ...', () async {
    var testData1 = '''
2,2,2
1,2,2
3,2,2
2,1,2
2,3,2
2,2,1
2,2,3
2,2,4
2,2,6
1,2,5
3,2,5
2,1,5
2,3,5
''';

    expect(Day18().solve(Day18.parseData(testData1)), equals(64));
    expect(Day18().solve(Day18.parseData(testData1), part2: true), equals(58));
  });
}
