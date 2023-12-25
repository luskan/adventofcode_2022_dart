import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

class BagItems {
  var c1 = "";
  var c2 = "";

  BagItems(this.c1, this.c2);
}
typedef InputList = List<BagItems>;

@DayTag()
class Day03 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static InputList parseData(var data) {
    return LineSplitter()
        .convert(data)
        .map((line) {
          if ((line.length % 2) != 0) {
            throw Exception("Non even line length");
          }
         return BagItems(line.substring(0, line.length~/2), line.substring(line.length~/2));
        }).toList();
  }

  int solve(InputList data, {var part2 = false}) {
    var total = 0;

    if (part2 == false) {
      total = data
          .map((e) => calculateSumOfPriorities(e))
          .reduce((value, element) => value + element);
    }
    else {
      for(var i = 0; i < data.length; i+=3){
        total += groupBadgePriority([data[i], data[i+1], data[i+2]]);
      }
    }
    return total;
  }

  int solve2(var data) {
    return 0;
  }

  @override
  Future<void> run() async {
    print("Day03");

    var data = readData("../adventofcode_input/2022/data/day03.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2022/data/day03_result.txt", 0));

    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2022/data/day03_result.txt", 1));
  }

  calculateSumOfPriorities(BagItems e) {
    var sum = 0;
    var itemCounts = <String, List<int>>{};
    if (e.c1.length != e.c2.length) {
      throw Exception("Wrong lengths");
    }
    storeItemCounts(e, 0, itemCounts);
    storeItemCounts(e, 1, itemCounts);
    for (var k in itemCounts.keys) {
      var v = itemCounts[k]!;
      if (v[0] >= 1 && v[1] >= 1) {
        int pr = typeToPrority(k);
        sum += pr;
      }
    }
    return sum;
  }

  int typeToPrority(String k) {
    var pr = k.codeUnits[0];
    if (pr >= 97 && pr <= 122) {
      pr = pr - 97 + 1;
    }
    else if (pr >= 65 && pr <= 90) {
      pr = pr - 65 + 27;
    }
    else {
      throw Exception("Unknown item");
    }
    return pr;
  }

  void storeItemCounts(BagItems e, int comp, Map<String, List<int>> itemCounts) {
    for (var c in (comp == 0 ? e.c1.runes : e.c2.runes)) {
      var cc = String.fromCharCode(c);
      if (itemCounts.containsKey(cc)) {
        var old = itemCounts[cc];
        if (comp == 0)
          itemCounts[cc] = [old![0]+1, old[1]];
        else
          itemCounts[cc] = [old![0], old[1]+1];
      }
      else {
        if (comp == 0)
          itemCounts[cc] = [1, 0];
        else
          itemCounts[cc] = [0, 1];
      }
    }
  }

  int groupBadgePriority(List<BagItems> bagItems) {
    var pr = 0;
    var typeCounts = <String, int>{};
    for (var e in bagItems) {
      var ic = <String, List<int>>{};
      storeItemCounts(e, 0, ic);
      storeItemCounts(e, 1, ic);
      for (var k in ic.keys) {
        if (typeCounts.containsKey(k)) {
          var v = typeCounts[k];
          typeCounts[k] = v==null ? 0 : v + 1;
        }
        else {
          typeCounts[k] = 1;
        }
      }
    }
    var badge = typeCounts.keys.firstWhere((element) => typeCounts[element] == 3, orElse: ()=>"?");
    if(badge.compareTo("?")==0){
      throw Exception("Error");
    }
    pr = typeToPrority(badge);
    return pr;
  }
}
