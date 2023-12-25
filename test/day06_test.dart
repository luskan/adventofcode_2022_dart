import 'package:test/test.dart';
import 'package:adventofcode_2022/day06.dart';

void main() {
  test('day06 ...', () async {
    var testData1 = [
      "mjqjpqmgbljsphdztnvjfqwrcgsmlb",
      "bvwbjplbgvbhsrlpgdmjqwftvncz",
      "nppdvjthqldpwncqszvftbrmjlhg",
      "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg",
      "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw"];
    var testData1Exp = [7, 5,6,10,11];
    var testData1ExpP2 = [19,23,23,29,26];
    for(var n = 0; n < testData1.length; n++) {
      expect(Day06().solve(Day06.parseData(testData1[n])), equals(testData1Exp[n]));
      expect(Day06().solve(Day06.parseData(testData1[n]), part2: true), equals(testData1ExpP2[n]));
    }
  });
}
