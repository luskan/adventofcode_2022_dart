import 'dart:io';
import 'dart:convert';
import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

class DataItem {
  String opcode = "";
  int value = 0;

  DataItem(this.opcode, this.value);
}
typedef DataItemList = List<DataItem>;

@DayTag()
class Day10 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static DataItemList parseData(var data) {
    var rg = RegExp(r'^(?<opcode>\w+)\s?(?<value>[-\d]*)$');
    return LineSplitter().convert(data)
      .map((e) {
        var m = rg.firstMatch(e);
        var opcode = m?.namedGroup("opcode") ?? "";
        var valueStr = m?.namedGroup("value") ?? "0";
        var value = valueStr.isEmpty ? 0 : int.parse(valueStr);

        return DataItem(opcode, value);
      }).toList();
  }

  int solve(DataItemList data) {
    var res = 0;
    var x = 1;
    var cycle = 0;
    for (var e in data) {

      if (e.opcode == "noop") {
        cycle++;
        if ([20, 60, 100, 140, 180, 220].contains(cycle))
          res += cycle * x;
      }
      else if (e.opcode == "addx") {
        cycle+=1;
        if ([20, 60, 100, 140, 180, 220].contains(cycle))
          res += cycle * x;

        cycle+=1;
        if ([20, 60, 100, 140, 180, 220].contains(cycle))
          res += cycle * x;
        x += e.value;
      }
    }
    return res;
  }

  String solve2(DataItemList data) {
    var x = 1;
    var cycle = 0;

    var output = <String>[];

    void tryAddPixel() {
      var column = ((cycle-1) % 40);
      var row = (cycle-1) ~/ 40;
      if (row >= output.length) {
        output.add("");
      }
      if (x-1 == column || x == column || x+1 == column) {
        output[row] += "#";
      }
      else {
        output[row] += ".";
      }
    }

    for (var e in data) {

      if (e.opcode == "noop") {
        cycle++;
        tryAddPixel();
      }
      else if (e.opcode == "addx") {
        cycle+=1;
        tryAddPixel();

        cycle+=1;
        tryAddPixel();

        x += e.value;
      }
    }
    return output.join("\n")+"\n";
  }

  @override
  Future<void> run() async {
    print("Day10");

    var data = readData("../adventofcode_input/2022/data/day10.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2022/data/day10_result.txt", 0));

    var res2 = solve2(data);
    print('Part2: \n$res2');
    verifyResult(res2.replaceAll('\n', ''),
        getStringFromFile("../adventofcode_input/2022/data/day10_result.txt", 1, end:7).replaceAll('\n', ''));
  }
}
