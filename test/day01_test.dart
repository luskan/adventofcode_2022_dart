import 'package:test/test.dart';
import 'package:adventofcode_2022/day01.dart';

void main() {
  test('day01 ...', () async {
    var testData1 = '''
1000
2000
3000

4000

5000
6000

7000
8000
9000

10000 
''';
    expect(Day01().solve(Day01.parseData(testData1)), equals(24000));
    expect(Day01().solve(Day01.parseData(testData1), part2: true), equals(45000));
  });
}
