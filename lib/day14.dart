import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:adventofcode_2022/common.dart';

import 'day.dart';
import 'solution_check.dart';

@DayTag()
class Day14 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static List parseData(var data) {

    List parsePathToTuples(String path) {
      return path.split(' -> ').map((point) {
        var coordinates = point.split(',');
        return Point(int.parse(coordinates[0]), int.parse(coordinates[1]));
      }).toList();
    }

    var lines = LineSplitter().convert(data);
    List result = [];
    for (var i = 0; i < lines.length; ++i) {
      var line = lines[i];
      if (line.isEmpty)
        continue;

      List points = parsePathToTuples(line);
      result.add(points);
    }

    return result;
  }

  int solve(List data, {var part2 = false}) {

    int rows = 1650;
    int cols = 800;

    List<List<int>> map = List.generate(rows, (i) => List.filled(cols, 0));


    var max_y = 0;
    var min_x = 100000;
    var max_x = 0;

    for (var line in data) {
      for (var i = 1; i < line.length; ++i) {
        var t1 = line[i-1] as Point;
        var t2 = line[i] as Point;

        map[t1.x][t1.y] = 1;
        map[t2.x][t2.y] = 1;

        if (t1.x == t2.x) {
          var sign = (t1.y < t2.y) ? 1 : -1;
          for (int y = t1.y; y != t2.y; y += sign) {
            map[t1.x][y] = 1;
            max_y = max(max_y, y);
            max_x = max(max_x, t1.x);
          }
        }

        if (t1.y == t2.y) {
          var sign = (t1.x < t2.x) ? 1 : -1;
          for (var x = t1.x; x != t2.x; x += sign) {
            map[x][t1.y] = 1;
            min_x = min(max_x, x);
            max_x = max(max_x, x);
            max_y = max(max_y, t1.y);
          }
        }

      }
    }

    if (part2) {
      for (var x = 0; x < max_x + 1000; ++x) {
        map[x][max_y+2] = 1;
      }
      max_y += 2;
    }

    min_x = 100000;
    max_x = 0;

    var result = 0;
    var done = false;
    while(!done) {
      var t = Point(500, 0); // replacing Point usage with variables gives around 10% speedup
      var t_prev = t;
      while (t.y < max_y+100 || part2) {
        if (map[t.x][t.y] != 0) {
          t = t_prev;
          if (map[t.x-1][t.y+1] == 0) {
            t = Point(t.x-1, t.y+1);
            t_prev = t;
          }
          else if (map[t.x+1][t.y+1] == 0) {
            t = Point(t.x+1, t.y+1);
            t_prev = t;
          }
          else {
            map[t.x][t.y] = 2;
            result++;
            max_x = max(max_x, t.x);
            min_x = min(min_x, t.x);

            if (t == Point(500, 0))
              done = true;
            break;
          }
        }
        else {
          t_prev = t;
          t = Point(t.x, t.y+1);
        }
      }
      if (!part2) {
        if (t.y > max_y) {
          break;
        }
      }
    }

/*
    for (var y = 0; y <= max_y+1; ++y) {
      for (var x = min_x-4; x < max_x+4; ++x) {
        var p = Point(x, y);
        if (map[x][y] != 0) {
          stdout.write(map[x][y] == 1 ? "#" : "o");
        }
        else {
          stdout.write(".");
        }
      }
      stdout.write("\n");
    }
    stdout.write("\n");stdout.write("\n");

  */

    return result;
  }

  @override
  Future<void> run() async {
    print("Day14");

    var data = readData("../adventofcode_input/2022/data/day14.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2022/data/day14_result.txt", 0));

    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2022/data/day14_result.txt", 1));
  }
}

