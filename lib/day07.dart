import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'package:adventofcode_2022/common.dart';

import 'day.dart';
import 'package:collection/collection.dart';
import 'solution_check.dart';

class CommandData {
  var isCommand = false;
  var c1 = "";
  var c2 = "";

  CommandData(this.isCommand, this.c1, this.c2);
}


@DayTag()
class Day07 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static List<CommandData> parseData(var data) {
    String reg = r'^(?<dollar>\$?)\s?(?<c1>[\w\d]+)\s?(?<c2>.*)$';
    RegExp rg = RegExp(reg);
    return LineSplitter()
        .convert(data)
        .map((line)
    {
      var matches = rg.allMatches(line);
      var match = matches.elementAt(0);
      var dollarGroup = (match.namedGroup("dollar") ?? "").compareTo("\$") == 0;

      var c1 = match.namedGroup("c1") ?? "";
      var c2 = match.namedGroup("c2") ?? "";
      CommandData data = CommandData(dollarGroup, c1, c2);

      return data;
    }).toList();
  }



  int solve(List<CommandData> data) {
    var sizesMap = <String, int>{};
    totalSize(data, 0, sizesMap);
    var res = 0;
    for (var v in sizesMap.values) {
      if (v <= 100000) {
        res += v;
      }
    }
    return res;
  }

  int solve2(List<CommandData> data) {
    var sizesMap = <String, int>{};
    totalSize(data, 0, sizesMap);

    var totalUsed = sizesMap["/"] ?? 0;
    var diskSize = 70000000;
    var neededFreeSize = 30000000;
    var mustBeFreedSize = neededFreeSize - (diskSize-totalUsed);

    return sizesMap
        .entries
        .map((e) => e.value)
        .sorted((a, b) => a - b)
        .firstWhere((e) => e >= mustBeFreedSize );
  }

  @override
  Future<void> run() async {
    print("Day07");

    var data = readData("../adventofcode_input/2022/data/day07.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2022/data/day07_result.txt", 0));

    var res2 = solve2(data);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2022/data/day07_result.txt", 1));
  }

  totalSize(List<CommandData> data, int i, Map<String, int> dirSizesMap) {
    var cwd = ["/"];
    for(;i < data.length;++i) {
      var d = data[i];
      if (d.isCommand) {
        if (d.c1 == "cd") {
          if (d.c2 == "/") {
            cwd.clear();
            cwd.add("/");
          }
          else if (d.c2 == "..") {
            cwd.removeLast();
          }
          else {
            cwd.add(d.c2);
          }
        }
        if (d.c1 == "ls") {

        }
      }
      else {
        if (d.c1 == "dir") {
            
        }
        else {
          int size = int.parse(d.c1);

          String curCwd = "";
          for (var i = 0; i < cwd.length; ++i) {
            if (i > 1) {
              curCwd += "/";
            }
            curCwd+=cwd[i];
            var old = dirSizesMap[curCwd] ?? 0;
            //print(curCwd + " file:${(cwd.join("/")+"/").replaceAll("//", "/") +d.c2}, size: ${old+size}");
            dirSizesMap[curCwd] = old + size;
          }
        }
      }
    }
  }
}
