import 'package:adventofcode_2022/day19.dart';
import 'package:test/test.dart';

void main() {
  test('day19 ...', () async {
    var testData1 = '''
Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.
Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.
''';

    expect(Day19().solve(Day19.parseData(testData1)), equals(33));
    expect(Day19().solve(Day19.parseData(testData1), timeLimit: 32, part2: true), equals(56*62));
  });
}
