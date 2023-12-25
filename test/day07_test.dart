import 'package:test/test.dart';
import 'package:adventofcode_2022/day07.dart';

void main() {
  test('day07 ...', () async {
    var testData1 = '''
\$ cd /
\$ ls
dir a
14848514 b.txt
8504156 c.dat
dir d
\$ cd a
\$ ls
dir e
29116 f
2557 g
62596 h.lst
\$ cd e
\$ ls
584 i
\$ cd ..
\$ cd ..
\$ cd d
\$ ls
4060174 j
8033020 d.log
5626152 d.ext
7214296 k    
''';

    expect(Day07().solve(Day07.parseData(testData1)), equals(95437));
    expect(Day07().solve2(Day07.parseData(testData1)), equals(24933642));
  });
}
