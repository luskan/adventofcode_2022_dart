import 'package:test/test.dart';
import 'package:adventofcode_2022/day13.dart';

void main() {
  test('day13 ...', () async {
    var testData1 = '''
[1,1,3,1,1]
[1,1,5,1,1]

[[1],[2,3,4]]
[[1],4]

[9]
[[8,7,6]]

[[4,4],4,4]
[[4,4],4,4,4]

[7,7,7,7]
[7,7,7]

[]
[3]

[[[]]]
[[]]

[1,[2,[3,[4,[5,6,7]]]],8,9]
[1,[2,[3,[4,[5,6,0]]]],8,9]
''';

    expect(Day13().solve(Day13.parseData(testData1)), equals(13));
    expect(Day13().solve(Day13.parseData(testData1), part2: true), equals(140));
  });
}
