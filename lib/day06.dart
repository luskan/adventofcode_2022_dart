import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'common.dart';
import 'day.dart';
import 'package:collection/collection.dart';
import 'solution_check.dart';

@DayTag()
class Day06 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static String parseData(var data) {
    return data;
  }

  int solve(String data, {var part2 = false}) {
    var res = 0;

    var map = <String, int>{};
    for(var k = 0; k < data.length; k++) {
      if(k>=3) {
        var found = true;
        for (var m = 0; m < (part2 ? 14 : 4); ++m) {
          var ind = k - m;
          if (map.containsKey(data[ind]) && map[data[ind]] == k) {
            found = false;
            break;
          }
          map[data[ind]] = k;
        }
        if (found) {
          res = k + 1;
          break;
        }
      }
    }

    return res;
  }

  int solve2(var data) {
    return 0;
  }

  @override
  Future<void> run() async {
    print("Day06");

    var data = readData("../adventofcode_input/2022/data/day06.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2022/data/day06_result.txt", 0));

    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2022/data/day06_result.txt", 1));
  }
}
