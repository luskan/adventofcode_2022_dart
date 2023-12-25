import 'package:adventofcode_2022/day17.dart';
import 'package:test/test.dart';

void main() {
  test('day17 ...', () async {
    var testData1 = '''
>>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>
''';

    expect(Day17().solve(Day17.parseData(testData1)), equals(3068));
    expect(Day17().solve(Day17.parseData(testData1), part2: true, part2RocksToThrow: 1000000000000), equals(1514285714288));
  });
}
