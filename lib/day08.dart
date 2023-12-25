import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'common.dart';
import 'day.dart';
import 'package:collection/collection.dart';
import 'solution_check.dart';

@DayTag()
class Day08 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static List<List<int>> parseData(var data) {
    var lines = LineSplitter().convert(data).toList();
    var res = List.generate(lines.length, (_) => List.filled(lines.length, 0));
    for (var row = 0; row < lines.length; ++row) {
      for (var col = 0; col < lines.length; ++col) {
        res[row][col] = lines[row].runes.elementAt(col) - 48/*'0'*/;
      }
    }
    return res;
  }

  int solve(List<List<int>> data, {var part2 = false}) {
    int res = part2 ? 0 : (data.length-1)*4;

    for (int r = 1; r < data.length-1; ++r) {
      for (int c = 1; c < data.length-1; ++c) {

        var cur = data[r][c];
        var abort = false;
        var i1=0,i2=0,i3=0,i4=0;

        // to left
        for (int c2 = c-1; c2 >= 0 && !abort; --c2) {
          var v = data[r][c2];
          if (v >= cur) {
            abort = true;
          }
          i1++;
        }
        if (!abort && !part2) {
          res++;
          continue;
        }
        abort = false;

        // to top
        for (int r2 = r-1; r2 >= 0 && !abort; --r2) {
          var v = data[r2][c];
          if (v >= cur) {
            abort = true;
          }
          i2++;
        }
        if (!abort && !part2) {
          res++;
          continue;
        }
        abort = false;

        // to right
        for (int c2 = c+1; c2 < data.length && !abort; ++c2) {
          var v = data[r][c2];
          if (v >= cur) {
            abort = true;
          }
          i3++;
        }
        if (!abort && !part2) {
          res++;
          continue;
        }
        abort = false;

        // to bottom
        for (int r2 = r+1; r2 < data.length && !abort; ++r2) {
          var v = data[r2][c];
          if (v >= cur) {
            abort = true;
          }
          i4++;
        }
        if (!abort && !part2) {
          res++;
          continue;
        }

        if (part2) {
          var mul = i1 * i2 * i3 * i4;
          if (mul > res)
            res = mul;
        }
      }
    }

    return res;
  }

  @override
  Future<void> run() async {
    print("Day08");

    var data = readData("../adventofcode_input/2022/data/day08.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2022/data/day08_result.txt", 0));

    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2022/data/day08_result.txt", 1));
  }
}
