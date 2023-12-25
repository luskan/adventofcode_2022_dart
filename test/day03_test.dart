import 'package:test/test.dart';
import 'package:adventofcode_2022/day03.dart';

void main() {
  test('day03 ...', () async {
    var testData1 = '''
vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw
''';
    expect(Day03().solve(Day03.parseData(testData1)), equals(157));
    expect(Day03().solve(Day03.parseData(testData1), part2: true), equals(70));
  });
}
