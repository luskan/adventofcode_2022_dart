import 'dart:io';
import 'dart:convert';
import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

typedef InputMap = Map<int, List<int>>;

@DayTag()
class Day01 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static InputMap parseData(var data) {
    var id = 1;
    var retMap = InputMap();
    LineSplitter()
        .convert(data)
        .map((element) {
          if (element.isEmpty) {
            id++;
            return [-1, -1];
          }
         return [id, int.parse(element)];
        })
        .where((el) => el[0] != -1)
        .toList()
        .forEach((el) {
          if (!retMap.containsKey(el[0])) {
            retMap[el[0]] = <int>[el[1]];
          } else {
            retMap[el[0]]!.add(el[1]);
          }
    });
    return retMap;
  }

  int solve(InputMap data, {var part2 = false}) {
   var totalList = <List<int>>[];
   for (var key in data.keys) {
    var sum = data[key]?.reduce((value, element) => value + element);
    totalList.add([key, sum!]);
   }
   totalList.sort((a, b) => b[1] - a[1]);

   return part2 ? totalList[0][1] + totalList[1][1] + totalList[2][1]: totalList[0][1];
  }

  int solve2(var data) {
    return 0;
  }

  @override
  Future<void> run() async {
    print("Day01");

    var data = readData("../adventofcode_input/2022/data/day01.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2022/data/day01_result.txt", 0));

    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2022/data/day01_result.txt", 1));
  }
}
