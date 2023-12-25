import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

@DayTag()
class Day18 extends Day with ProblemReader, SolutionCheck {

  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static Set<Point3> parseData(String data) {
    var s = <Point3>{};
    LineSplitter().convert(data).forEach((line) {
      var parts = line.split(",");
      int x = int.parse(parts[0].trim());
      int y = int.parse(parts[1].trim());
      int z = int.parse(parts[2].trim());
      s.add(Point3(x, y, z));
    });
    return s;
  }

  bool checkPoint(int xOff, int yOff, int zOff, Point3 pt, Set<Point3> scan) {
    Point3 ptTmp = Point3(pt.x + xOff, pt.y + yOff, pt.z + zOff);
    if (scan.contains(ptTmp)) {
      return true;
    }
    return false;
  }

  int solve(Set<Point3> scan, {var part2 = false}) {
    int result = 0;
    for (var pt in scan) {
      result += checkPoint(1, 0, 0, pt, scan) ? 0 : 1;
      result += checkPoint(-1, 0, 0, pt, scan) ? 0 : 1;

      result += checkPoint(0, 1, 0, pt, scan) ? 0 : 1;
      result += checkPoint(0, -1, 0, pt, scan) ? 0 : 1;

      result += checkPoint(0, 0, 1, pt, scan) ? 0 : 1;
      result += checkPoint(0, 0, -1, pt, scan) ? 0 : 1;
    }

    if (part2) {

      // Find all candidates for air cubes, those will be neighbours of each side of the scanned points.
      // Its imporatant that the air cubes can connect inside the lava and form large groups, so in here
      // we only find some of the candidates, and then we recurse to find the rest.
      var candidates = <Point3>{};
      for (var pt in scan) {
        var points = <Point3>{
          Point3(pt.x + 1, pt.y, pt.z),
          Point3(pt.x - 1, pt.y, pt.z),
          Point3(pt.x, pt.y + 1, pt.z),
          Point3(pt.x, pt.y - 1, pt.z),
          Point3(pt.x, pt.y, pt.z + 1),
          Point3(pt.x, pt.y, pt.z - 1),
        };

        for (var p in points) {
          if (!scan.contains(p)) {
            candidates.add(p);
          }
        }
      }

      // Find min/max of scan points
      int minX = maxInt;
      int maxX = minInt;
      int minY = maxInt;
      int maxY = minInt;
      int minZ = maxInt;
      int maxZ = minInt;
      for (var pt in scan) {
        minX = min(minX, pt.x);
        maxX = max(maxX, pt.x);
        minY = min(minY, pt.y);
        maxY = max(maxY, pt.y);
        minZ = min(minZ, pt.z);
        maxZ = max(maxZ, pt.z);
      }
      var min3 = Point3(minX, minX, minY);
      var max3 = Point3(maxY, maxZ, maxZ);

      // This set will contain points which are proven to be air cubes. We must skip candidates
      // which has the same point from proven air cube.
      Set<Point3> candidatesToSkip = <Point3>{};

      // Counter which finds the number of lava walls touched by the air
      var scanWallsTouched = PrimitiveWrapper<int>(0);
      Set<Point3> visited = <Point3>{};

      // Now for each candidate which can be in air trapped inside the lava.
      for (var pt in candidates) {

        // Check if it is already proven to be air
        if (candidatesToSkip.contains(pt)) {
          continue;
        }

        visited.clear();
        scanWallsTouched.value = 0;
        if (recurseFill(pt, visited, scan, scanWallsTouched, min3, max3)) {
          // Found new air group which is trapped inside lava.
          result -= scanWallsTouched.value;
          candidatesToSkip.addAll(visited);
        }
      }
    }

    return result;
  }

  bool recurseFill(Point3 pt, Set<Point3> visited, Set<Point3> scan, PrimitiveWrapper<int> scanWallsTouched,
      Point3 min, Point3 max)
  {
    visited.add(pt);

    var points = <Point3>{
      Point3(pt.x + 1, pt.y, pt.z),
      Point3(pt.x - 1, pt.y, pt.z),
      Point3(pt.x, pt.y + 1, pt.z),
      Point3(pt.x, pt.y - 1, pt.z),
      Point3(pt.x, pt.y, pt.z + 1),
      Point3(pt.x, pt.y, pt.z - 1),
    };

    for (var p in points) {
      if (p.x < min.x || p.x > max.x || p.y < min.y || p.y > max.y ||
          p.z < min.z || p.z > max.z) {
        // Outside of range
        return false;
      }
      if (visited.contains(p)) {
        // Already seen this point
        continue;
      }
      if (scan.contains(p)) {
        // Its a wall,
        scanWallsTouched.value++;
        continue;
      }
      if (!recurseFill(p, visited, scan, scanWallsTouched, min, max))
        return false;
    }
    return true;
  }

  @override
  Future<void> run() async {
    print("Day18");

    var data = readData("../adventofcode_input/2022/data/day18.txt");
    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2022/data/day18_result.txt", 0));

    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2022/data/day18_result.txt", 1));
  }

}

