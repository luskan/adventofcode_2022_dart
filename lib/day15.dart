import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:adventofcode_2022/common.dart';

import 'day.dart';
import 'solution_check.dart';

class Sensor {
  final Point pos;
  final Point beacon;
  final int mdist;
  const Sensor(this.pos, this.beacon, this.mdist);
}

class Edge {
  final Point p1;
  final Point p2;
  const Edge(this.p1, this.p2);
}

@DayTag()
class Day15 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static List<Sensor> parseData(var data) {
    List<Sensor> res = [];

    LineSplitter().convert(data).forEach((line) {
      if (line.isEmpty)
        return;

      var matches = RegExp(r'^Sensor at x=(?<x>[-\d]+), y=(?<y>[-\d]+): closest beacon is at x=(?<bx>[-\d]+), y=(?<by>[-\d]+)$').allMatches(line);
      var match = matches.elementAt(0);
      var x = int.parse(match.namedGroup("x") ?? "");
      var y = int.parse(match.namedGroup("y") ?? "");
      var bx = int.parse(match.namedGroup("bx") ?? "");
      var by = int.parse(match.namedGroup("by") ?? "");
      res.add(Sensor(Point(x, y), Point(bx, by), (bx-x).abs() + (by-y).abs()));
    });
    return res;
  }

  int solve(List<Sensor> data, {var part2 = false, int y = 0, int max_xy = 4000000, int frequency_mul = 4000000}) {
    if (!part2) {
      var intervals = <IntRange>[];
      data.forEach((sensor) {
        int dist_y = sensor.mdist - (sensor.pos.y - y).abs();
        if (dist_y >= 0) {
          intervals.add(
              IntRange(sensor.pos.x - dist_y, sensor.pos.x + dist_y));
        }
      });
      var merged = mergeOverlappingIntervals(intervals);
      var count = merged.fold<int>(0, (acc, el) => acc + el.end - el.start);
      return count;
    }
    else {
      var result = -1;
      var edges = <Line>[];
      data.forEach((s) {
        int dist = s.mdist + 1;
        /*
        --> /\
            \/
         */
        edges.add(Line(Point(s.pos.x - dist, s.pos.y), Point(s.pos.x, s.pos.y - dist)));

        /*
            /\ <--
            \/
         */
        edges.add(Line(Point(s.pos.x, s.pos.y - dist), Point(s.pos.x + dist, s.pos.y)));

        /*
            /\
            \/ <--
         */
        edges.add(Line(Point(s.pos.x + dist, s.pos.y), Point(s.pos.x, s.pos.y + dist)));

        /*
            /\
        --> \/
         */
        edges.add(Line(Point(s.pos.x - dist, s.pos.y), Point(s.pos.x, s.pos.y + dist)));
      });

      for (var line in edges) {

        // Calculate the difference in coordinates
        int dx = line.p2.x.toInt() - line.p1.x.toInt();
        int dy = line.p2.y.toInt() - line.p1.y.toInt();

        // Calculate the steps needed to iterate from p1 to p2
        int steps = max(dx.abs(), dy.abs());

        // Calculate the increment for each step
        int xIncrement = dx ~/ steps;
        int yIncrement = dy ~/ steps;

        // Starting point
        int x = line.p1.x;
        int y = line.p1.y;

        // Clamp
        if (x < 0) {
          y += (0 - x) * yIncrement;
          x = 0;
        }
        if (x > max_xy) {
          y += (max_xy - x) * yIncrement;
          x = max_xy;
        }
        if (y < 0) {
          x += (0 - y) * xIncrement;
          y = 0;
        }
        if (y > max_xy) {
          x += (max_xy - y) * xIncrement;
          y = max_xy;
        }

        // Find cases when we are already outside the map
        if (x == 0 && xIncrement < 0) {
          continue;
        }
        if (x == max_xy && xIncrement > 0) {
          continue;
        }
        if (y == 0 && yIncrement < 0) {
          continue;
        }
        if (y == max_xy && yIncrement > 0) {
          continue;
        }

        // Iterate over the line
        for (int i = 0; i <= steps; i++) {
          // Move to the next point
          x += xIncrement.toInt();
          y += yIncrement.toInt();

          if (x < 0 || x > max_xy || y < 0 || y > max_xy)
            break;

          var found = true;
          for (var s in data) {
            int ppd = (x - s.pos.x).abs() + (y - s.pos.y).abs();
            if (ppd <= s.mdist) {
              found = false;
              // Skip to the middle of the line
              int dist_out = (s.mdist - ppd)~/2;
              x += xIncrement.toInt()*dist_out;
              y += yIncrement.toInt()*dist_out;
              i += dist_out;
              break;
            }
          }
          if (found) {
            result = x * frequency_mul + y;
            //print("Found: $result");
            break;
          }
        }
        if (result != -1)
          break;
      }

      return result;
    }
  }

  @override
  Future<void> run() async {
    print("Day15");

    var data = readData("../adventofcode_input/2022/data/day15.txt");

    var res1 = solve(data, y: 2000000);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2022/data/day15_result.txt", 0));

    var res2 = solve(data, part2: true, max_xy: 4000000);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2022/data/day15_result.txt", 1));
  }
}

