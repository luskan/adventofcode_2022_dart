import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

class StrategyItem {
  var p1 = "";
  var p2 = "";

  StrategyItem(this.p1, this.p2);

  bool isDraw() { return p1.compareTo(toRegular(p2)) == 0; }

  bool isP2Wins() {
    //A for Rock, B for Paper, and C for Scissors
    var a = p1;
    var b = toRegular(p2);
    if (a.compareTo("A") == 0 && b.compareTo("B") == 0)
      return true;
    if (a.compareTo("B") == 0 && b.compareTo("C") == 0)
      return true;
    if (a.compareTo("C") == 0 && b.compareTo("A") == 0)
      return true;
    return false;
  }

  String toRegular(String p2) {
    switch(p2) {
      case "X": return "A";
      case "Y": return "B";
      case "Z": return "C";
    }
    throw Exception("Unknown move");
  }
}
typedef InputList = List<StrategyItem>;

@DayTag()
class Day02 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static InputList parseData(var data) {
    return LineSplitter()
        .convert(data)
        .map((line) {
         return StrategyItem(line[0], line[2]);
        }).toList();
  }

  int solve(InputList data, {var part2 = false}) {
    var total = data.map((e) => part2 ? calculateRound2(e) : calculateRound(e))
        .reduce((value, element) => value + element);
   return total;
  }

  int solve2(var data) {
    return 0;
  }

  @override
  Future<void> run() async {
    print("Day02");

    var data = readData("../adventofcode_input/2022/data/day02.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2022/data/day02_result.txt", 0));

    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2022/data/day02_result.txt", 1));
  }

  int calculateRound(StrategyItem e) {
    var sum = 0;
    switch(e.p2) {
      case "X":
        sum = 1;
        break;
      case "Y":
        sum = 2;
        break;
      case "Z":
        sum = 3;
        break;
      default:
        throw Exception("Unknown");
        break;
    }
    if (e.isDraw()){
      sum += 3;
    }
    else if (e.isP2Wins()){
      sum += 6;
    }
    return sum;
  }

  calculateRound2(StrategyItem e) {
    var p2 = "";
    switch(e.p2) {
      case "X":
        //lose
        switch(e.p1) {
          case "A": // rock
            p2 = "Z"; // scisors
            break;
          case "B": // paper
            p2 = "X"; // rock
            break;
          case "C": // scisors
            p2 = "Y"; // paper
            break;
        }
        break;
      case "Y":
        //draw
        switch(e.p1) {
          case "A": // rock
            p2 = "X";
            break;
          case "B": // paper
            p2 = "Y";
            break;
          case "C": // scisors
            p2 = "Z";
            break;
        }
        break;
      case "Z":
        //win
        switch(e.p1) {
          case "A": // rock
            p2 = "Y"; // paper
            break;
          case "B": // paper
            p2 = "Z"; // scisors
            break;
          case "C": // scisors
            p2 = "X"; // rock
            break;
        }
        break;
    }

    var newE = StrategyItem(e.p1, p2);
    return calculateRound(newE);
  }
}
