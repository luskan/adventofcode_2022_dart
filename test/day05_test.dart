import 'package:test/test.dart';
import 'package:adventofcode_2022/day05.dart';

void main() {
  test('day05 ...', () async {
    var testData1 = '''
    [D]    
[N] [C]    
[Z] [M] [P]
 1   2   3 

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2
''';
    expect(Day05().solve(Day05.parseData(testData1)), equals("CMZ"));
    expect(Day05().solve(Day05.parseData(testData1), part2: true), equals("MCD"));
  });
}
