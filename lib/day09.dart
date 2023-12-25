import 'dart:io';
import 'dart:convert';
import 'package:adventofcode_2022/common.dart';

import 'day.dart';
import 'solution_check.dart';

class DataItem {
  String dir = "";
  int steps = 0;

  DataItem(this.dir, this.steps);
}
typedef DataItemList = List<DataItem>;

@DayTag()
class Day09 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static DataItemList parseData(var data) {
    var rg = RegExp(r'^(?<dir>[DRLU]) (?<steps>\d+)$');
    return LineSplitter().convert(data)
      .map((e) {
        var m = rg.firstMatch(e);
        var dir = m?.namedGroup("dir") ?? "";
        var steps = int.parse(m?.namedGroup("steps") ?? "");
        return DataItem(dir, steps);
      }).toList();
  }

  int solve(DataItemList data, {var part2 = false}) {
    var tailMap = <Point, int>{};

    var nodes = <Point>[];
    for(var n = 0; n < (part2?10:2); n++) {
      nodes.add(Point(0, 0));
    }
    for (var n = 0; n < nodes.length-1; ++n) {
      tailMap[Point.clone(nodes[n])] = 1;
    }
    for (var e in data) {
      for (var st = 0; st < e.steps; ++st) {
        switch (e.dir) {
          case "U":
            nodes[0].y -= 1;
            break;
          case "D":
            nodes[0].y += 1;
            break;
          case "L":
            nodes[0].x -= 1;
            break;
          case "R":
            nodes[0].x += 1;
            break;
        }
        for (var n = 1; n < nodes.length; ++n) {
          nodes[n] = tailFollowHead(nodes[n], nodes[n-1]);
            if (n == nodes.length - 1) {
              tailMap[Point.clone(nodes[n])] = 1;
            }
        }
      }
    }

    return tailMap.length;
  }

  @override
  Future<void> run() async {
    print("Day09");

    var data = readData("../adventofcode_input/2022/data/day09.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2022/data/day09_result.txt", 0));

    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2022/data/day09_result.txt", 1));
  }

  Point tailFollowHead(Point tail, Point head) {
    if ( (tail.x - head.x).abs() <= 1 && (tail.y - head.y).abs() <= 1) {
      return tail;
    }
    var newTail = Point.clone(tail);
    if ((newTail.x - head.x).abs() > 1) {
      newTail.x += (head.x - newTail.x).sign;
      if ((newTail.y - head.y).abs() >= 1) {
        newTail.y += (head.y - newTail.y).sign;
      }
    }
    if ((newTail.y - head.y).abs() > 1) {
      newTail.y += (head.y - newTail.y).sign;
      if ((newTail.x - head.x).abs() >= 1) {
        newTail.x += (head.x - newTail.x).sign;
      }
    }

    assert( (newTail.x - head.x).abs() <= 1 );
    assert( (newTail.y - head.y).abs() <= 1 );

    return newTail;
  }
}
