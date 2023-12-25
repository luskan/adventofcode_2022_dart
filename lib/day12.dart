import 'dart:io';
import 'dart:convert';

import 'package:collection/collection.dart';

import 'package:adventofcode_2022/common.dart';

import 'package:tuple/tuple.dart';

import 'day.dart';
import 'solution_check.dart';

class Cell {
  int height = 0;
  int distFromStart = maxInt; // Also, indicates that node was visited (if non maxInt)
  Point prevNode = Point(0, 0);
  Cell(this.height, this.distFromStart, this.prevNode);
}
typedef CellMap = Map<Point, Cell>;
typedef ParsedTuple = Tuple5<CellMap, Point, Point, int, int>; // cellmap, start, end, width, height

@DayTag()
class Day12 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static ParsedTuple parseData(var data) {
    CellMap cellMap = {};
    Point start = Point(0,0);
    Point end = Point(0,0);
    var lineList = LineSplitter().convert(data);
    int width = 0;
    int height = 0;
    width = lineList[0].length;
    for (var y = 0; y < lineList.length; y++) {
      var line = lineList[y];
      height++;
      for (var x = 0; x < line.length; ++x) {
        var c = line[x];
        int height = 0;
        if (c == "S") {
          start = Point(x, y);
          height = "a".runes.elementAt(0) - 97;
        }
        else if (c == 'E') {
          end = Point(x, y);
          height = "z".runes.elementAt(0) - 97;
        }
        else {
          height = line.runes.elementAt(x) - 97;
        }
        cellMap[Point(x,y)] = Cell(height, maxInt, Point(0,0));
      }
    }
    return ParsedTuple(cellMap, start, end, width, height);
  }

  // solution uses dijkstra's algorithm
  int solve(ParsedTuple data, {var part2 = false}) {
    var cellMap = data.item1;
    var unvisited = PriorityQueue<Point>((a,b)
    {
      int d1 = cellMap[a]!.distFromStart;
      int d2 = cellMap[b]!.distFromStart;
      assert(d1 != maxInt);
      assert(d2 != maxInt);
      return d1 - d2;
    });
    var start = data.item2;
    var end = data.item3;
    var width = data.item4;
    var height = data.item5;

    //cellMap.keys.forEach((element) {unvisited.add(element);});

    cellMap[end]?.distFromStart = 0;
    unvisited.add(end);

    void tryAddNextPathNode(int xOff, int yOff, Point prevNodePos) {
      var x = prevNodePos.x + xOff;
      var y = prevNodePos.y + yOff;
      if (x < 0 || x >= width) {
        return;
      }
      if (y < 0 || y >= height) {
        return;
      }
      var nodePos = Point(x,y);
      if (!cellMap.containsKey(nodePos)) {
        throw Exception("");
      }
      var node = cellMap[nodePos]!;
      if (node.distFromStart != maxInt) {
        return;
      }
      var prevNode = cellMap[prevNodePos]!;

      var diff = node.height - prevNode.height;
      if (diff < -1) {
        return;
      }

      var newCost = 1 + prevNode.distFromStart;
      if (newCost < node.distFromStart) {
        node.distFromStart = newCost;
        node.prevNode = prevNodePos;
      }
      unvisited.add(nodePos);
    }

    while(unvisited.isNotEmpty) {
      var nod = unvisited.removeFirst();
      tryAddNextPathNode(0, -1, nod);
      tryAddNextPathNode(-1, 0, nod);
      tryAddNextPathNode(1, 0, nod);
      tryAddNextPathNode(0, 1, nod);
    }

    var res = 0;
    if (part2) {
      var bestPosDist = maxInt;
      for (var it in cellMap.entries) {
        if (it.value.height != 0) {
          continue;
        }
        if (it.value.distFromStart < bestPosDist) {
          bestPosDist = it.value.distFromStart;
        }
      }
      res = bestPosDist;
    }
    else {
      assert(cellMap[start]?.distFromStart != maxInt);
      res = cellMap[start]?.distFromStart ?? -1;
    }
    return res;
  }

  @override
  Future<void> run() async {
    print("Day12");

    var data = readData("../adventofcode_input/2022/data/day12.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2022/data/day12_result.txt", 0));

    data = readData("../adventofcode_input/2022/data/day12.txt");
    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2022/data/day12_result.txt", 1));
  }
}

