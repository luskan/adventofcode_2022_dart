import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'common.dart';
import 'day.dart';
import 'package:collection/collection.dart';
import 'solution_check.dart';

class Lane {
  var e = <String>[];
}

class Move {
  var count = 0;
  var from = 0;
  var to = 0;

  Move(this.count, this.from, this.to);
}

class Instructions {
  var lanes = <Lane>[];
  var moves = <Move>[];
}

@DayTag()
class Day05 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static Instructions parseData(var data) {
    var regMatch = r'^\[([A-Z])\]$';
    var regMatch2 = r'^move (\d+) from (\d+) to (\d+)$';
    Instructions instructions = Instructions();
    RegExp rg = RegExp(regMatch);
    RegExp rg2 = RegExp(regMatch2);
    var mode = 0;
    LineSplitter()
        .convert(data)
        .toList()
        .forEach((line) {
          if (mode == 0) {
            if (line.isEmpty) {
              mode = 1;
              return;
            }
            if (line.substring(0, 2).compareTo(" 1") == 0) {
              return;
            }
            var totalLines = (line.length+1)/4;
            if (instructions.lanes.length != totalLines) {
              for (var i = 0; i < totalLines; ++i) {
                instructions.lanes.add(Lane());
              }
            }
            for (var i = 0; i < totalLines; ++i) {
              var laneItem = line.substring(i*4, i*4 + 3);
              if (laneItem.trim().isEmpty) {
                continue;
              }
              var match = rg.allMatches(laneItem);
              if (match.isNotEmpty) {
                var m = match.elementAt(0);
                var it = m.group(1)!;
                instructions.lanes[i].e.add(it);
              }
              else {
                throw Exception("Should not be empty");
              }
            }
          }
          else {
            var matches = rg2.allMatches(line);
            var el = matches.elementAt(0);
            var count = el.group(1)!;
            var from = el.group(2)!;
            var to = el.group(3)!;
            instructions.moves.add(Move(
                int.parse(count),
                int.parse(from),
                int.parse(to)));
          }
        });
    return instructions;
  }

  String solve(Instructions data, {var part2 = false}) {
    for (var e in data.moves) {
      for (var i = 0; i < e.count; ++i) {
        var top = data.lanes[e.from - 1].e[0];
        data.lanes[e.from - 1].e.removeAt(0);
        data.lanes[e.to - 1].e.insert(0, top);
      }
      if (part2) {
        for (var i = 0; i < e.count/2; ++i) {
          data.lanes[e.to - 1].e.swap(i, e.count-1-i);
        }
      }
    }

    var res = "";

    for (var i = 0; i < data.lanes.length; ++i) {
      if (data.lanes.isEmpty)
        continue;
      res += data.lanes[i].e.first;
    }

    //total = data
    //      .map((e) => isAssignmentOverlap(e, part2) ? 1 : 0)
    //      .reduce((value, element) => value + element);

    return res;
  }

  int solve2(var data) {
    return 0;
  }

  @override
  Future<void> run() async {
    print("Day05");

    var data = readData("../adventofcode_input/2022/data/day05.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getStringFromFile("../adventofcode_input/2022/data/day05_result.txt", 0));

    data = readData("../adventofcode_input/2022/data/day05.txt");
    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getStringFromFile("../adventofcode_input/2022/data/day05_result.txt", 1));
  }
}
