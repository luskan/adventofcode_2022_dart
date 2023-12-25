import 'package:adventofcode_2022/day16.dart';
import 'package:test/test.dart';

void main() {
  test('day16 ...', () async {
    var testData1 = '''
Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
Valve BB has flow rate=13; tunnels lead to valves CC, AA
Valve CC has flow rate=2; tunnels lead to valves DD, BB
Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
Valve EE has flow rate=3; tunnels lead to valves FF, DD
Valve FF has flow rate=0; tunnels lead to valves EE, GG
Valve GG has flow rate=0; tunnels lead to valves FF, HH
Valve HH has flow rate=22; tunnel leads to valve GG
Valve II has flow rate=0; tunnels lead to valves AA, JJ
Valve JJ has flow rate=21; tunnel leads to valve II
''';

    var data = Day16.parseData(testData1);
    expect(Day16().solve(data), equals(1651));
    data = Day16.parseData(testData1);
    expect(Day16().solve(data, part2: true, maxRounds: 26), equals(1707));
  });
}
