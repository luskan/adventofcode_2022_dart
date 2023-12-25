import 'dart:io';
import 'dart:convert';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

class DataItem {
  int id = 0;
  List<int> startingItems = [];
  String op1="",op="",op2="";
  int divBy=0;
  int throwToIfTrue=0;
  int throwToIfFalse=0;
  int inspectedItems = 0;

  DataItem(this.id, this.startingItems, this.op1, this.op, this.op2, this.divBy,
      this.throwToIfTrue, this.throwToIfFalse){
    assert(op1.isNotEmpty);
    assert(op.isNotEmpty);
    assert(op2.isNotEmpty);
  }
}
typedef DataItemList = List<DataItem>;

@DayTag()
class Day11 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static DataItemList parseData(var data) {
    var rgId = RegExp(r'^Monkey (?<id>\w+):$');
    var rgStartingItems = RegExp(r'^\s*Starting items: (?<items>[\d\s,]+)$');
    var rgOperation = RegExp(r'^\s*Operation: new = (?<op1>[a-z]+)\s*(?<op>[\\*+\-/])\s*(?<op2>[a-z0-9]+)$');
    var rgTest = RegExp(r'^\s*Test: divisible by (?<divby>\d+)$');
    var rgTestTrue = RegExp(r'^\s*If true: throw to monkey (?<throwto>\d+)$');
    var rgTestFalse = RegExp(r'^\s*If false: throw to monkey (?<throwto>\d+)$');

    DataItemList resList = [];

    var lineList = LineSplitter().convert(data);
    for (var n = 0; n < lineList.length; ) {
      var mId = rgId.firstMatch(lineList[n++]);
      var mStartingItems = rgStartingItems.firstMatch(lineList[n++]);
      var mOperation = rgOperation.firstMatch(lineList[n++]);
      var mTest = rgTest.firstMatch(lineList[n++]);
      var mTestTrue = rgTestTrue.firstMatch(lineList[n++]);
      var mTestFalse = rgTestFalse.firstMatch(lineList[n++]);
      n++;

      int id = int.parse(mId?.namedGroup("id")??"");

      String times = mStartingItems?.namedGroup("items")??"";
      assert(times.isNotEmpty);
      List<int> startingTimes = times.split(", ").map((e) => int.parse(e)).toList();

      resList.add(DataItem(
        id, startingTimes,
          mOperation?.namedGroup("op1")??"",
          mOperation?.namedGroup("op")??"",
          mOperation?.namedGroup("op2")??"",
        int.parse(mTest?.namedGroup("divby")??""),
        int.parse(mTestTrue?.namedGroup("throwto")??""),
        int.parse(mTestFalse?.namedGroup("throwto")??"")
      ));
    }
    return resList;
  }

  int solve(DataItemList data, {var part2 = false}) {
    var modAll = data.map((e) => e.divBy).reduce((value, element) => element * value);
    for (var round = 0; round < (part2 ? 10000 : 20); ++round) {
      for (var i = 0; i < data.length; ++i) {
        DataItem m = data[i];
        for (var k = 0; k < m.startingItems.length; ++k) {
          var item = m.startingItems[k];
          int v1 = m.op1=="old" ? item : int.parse(m.op1);
          int v2 = m.op2=="old" ? item : int.parse(m.op2);
          late int result;
          switch(m.op) {
            case "*":
              result = v1 * v2;
              break;
            case "+":
              result = v1 + v2;
              break;
            default:
              assert(false);
          }
          if (!part2) {
            result = result ~/ 3;
          }
          else {
            result = result % modAll;
          }
          var dv = result % m.divBy;
          if (dv == 0) {
            data[m.throwToIfTrue].startingItems.add(result);
          }
          else {
            data[m.throwToIfFalse].startingItems.add(result);
          }
        }
        m.inspectedItems += m.startingItems.length;
        m.startingItems.clear();
      }
    }

    var mostActive = data.map((e) => e.inspectedItems).toList();
    mostActive.sort((a, b) => (b-a) < 0 ? -1 : 1 );
    return mostActive[0] * mostActive[1];
  }

  @override
  Future<void> run() async {
    print("Day11");

    var data = readData("../adventofcode_input/2022/data/day11.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2022/data/day11_result.txt", 0));

    data = readData("../adventofcode_input/2022/data/day11.txt");
    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2022/data/day11_result.txt", 1));
  }
}
