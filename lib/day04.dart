import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

class Interval {
  var a = 0;
  var b = 0;

  Interval(this.a, this.b);
}
class IntervalPair {
  Interval i1 = Interval(0,0);
  Interval i2 = Interval(0,0);

  IntervalPair(this.i1, this.i2);
}
typedef InputList = List<IntervalPair>;

@DayTag()
class Day04 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static InputList parseData(var data) {
    var regMatch = r'^(\d+)-(\d+),(\d+)-(\d+)$';
    RegExp rg = RegExp(regMatch);
    return LineSplitter()
        .convert(data)
        .map((line) {
          var match = rg.allMatches(line);
          var m = match.elementAt(0);
          var g1 = m.group(1);
          var i1a = int.parse(g1!);
          var i1b = int.parse(m.group(2)!);
          var i2a = int.parse(m.group(3)!);
          var i2b = int.parse(m.group(4)!);
          return IntervalPair(Interval(i1a, i1b), Interval(i2a, i2b));
        }).toList();
  }

  int solve(InputList data, {var part2 = false}) {
    var total = 0;

    total = data
          .map((e) => isAssignmentOverlap(e, part2) ? 1 : 0)
          .reduce((value, element) => value + element);

    return total;
  }

  int solve2(var data) {
    return 0;
  }

  @override
  Future<void> run() async {
    print("Day04");

    var data = readData("../adventofcode_input/2022/data/day04.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2022/data/day04_result.txt", 0));

    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2022/data/day04_result.txt", 1));
  }

  isAssignmentOverlap(IntervalPair e, part2) {
    if (part2) {
      if (e.i1.a >= e.i2.a && e.i1.a <= e.i2.b) {
        return true;
      }
      if (e.i1.b >= e.i2.a && e.i1.b <= e.i2.b) {
        return true;
      }
      if (e.i2.a >= e.i1.a && e.i2.a <= e.i1.b) {
        return true;
      }
      if (e.i2.b >= e.i1.a && e.i2.b <= e.i1.b) {
        return true;
      }
    }
    else {
      if (e.i1.a >= e.i2.a && e.i1.b <= e.i2.b) {
        return true;
      }
      if (e.i2.a >= e.i1.a && e.i2.b <= e.i1.b) {
        return true;
      }
    }
    return false;
  }
}
