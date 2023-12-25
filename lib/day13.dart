import 'dart:io';
import 'dart:convert';

import 'package:tuple/tuple.dart';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

class Packet {
  Node root = Node();

  Packet(this.root);
}
class Node {
  var childs = <dynamic>[]; // we want to put int and Node values here
  var isVirtual = false;
}

typedef PairOfPackets = Tuple2<Packet, Packet>;
typedef ListOfPacketsPairs = List<PairOfPackets>;

@DayTag()
class Day13 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static ListOfPacketsPairs parseData(var data) {

    Node parsePacket(String line) {
      int k = 1;
      Node parseNodes(String data) {
        var nod = Node();

        for (; k < data.length; ++k) {
          var c = data[k];

          if (c == ",") {
            continue;
          }

          if (c == "[") {
            k++;
            nod.childs.add(parseNodes(data));
            continue;
          }

          if (c == "]") {
            break;
          }

          int ind = data.indexOf(RegExp(r'[^\d]'), k);
          var value = int.tryParse(data.substring(k, ind));
          if (value != null) {
            nod.childs.add(value);
            k = ind-1;
            continue;
          }

          assert(false);
        }
        return nod;
      }
      return parseNodes(line);
    }

    var list = <PairOfPackets>[];

    var lines = LineSplitter().convert(data);
    for (var i = 0; i < lines.length; ++i) {
      var line = lines[i];
      if (line.isEmpty) {
        continue;
      }

      var n1 = parsePacket(line);
      i++;
      var n2 = parsePacket(lines[i]);
      list.add(PairOfPackets(Packet(n1), Packet(n2)));
    }

    return list;
  }

  int solve(ListOfPacketsPairs data, {var part2 = false}) {
    int res = 0;
    if (part2) {
      var divPackets = parseData("[[2]]\n[[6]]\n");
      var lst = <Packet>[];
      lst.add(divPackets[0].item1);
      lst.add(divPackets[0].item2);
      for (var i = 0; i < data.length; ++i) {
        lst.add(data[i].item1);
        lst.add(data[i].item2);
      }
      lst.sort((a, b) => checkRecursivelyIfCorrect(a.root, b.root));
      int ind1 = lst.indexOf(divPackets[0].item1);
      int ind2 = lst.indexOf(divPackets[0].item2);
      res = (ind1+1) * (ind2+1);
    }
    else {
      for (var i = 0; i < data.length; ++i) {
        var b = hasRightOrder(data[i]);
        if (b) {
          res += i + 1;
        }
      }
    }

    return res;
  }

  @override
  Future<void> run() async {
    print("Day13");

    var data = readData("../adventofcode_input/2022/data/day13.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2022/data/day13_result.txt", 0));

    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2022/data/day13_result.txt", 1));
  }

  bool hasRightOrder(Tuple2<Packet, Packet> data) {
    var v = checkRecursivelyIfCorrect(data.item1.root, data.item2.root);
    return v <= 0;
  }

  int checkRecursivelyIfCorrect(Node n1, Node n2) {

    for (var i = 0; ; ++i) {
      if (i >= n1.childs.length || i >= n2.childs.length) {
        if (n1.childs.length == n2.childs.length) {
          return 0;
        }
        else if (i >= n1.childs.length) {
          return -1;
        }
        else if (i >= n2.childs.length) {
          return 1;
        }
        assert(false);
      }

      dynamic v1 = n1.childs[i];
      dynamic v2 = n2.childs[i];
      if (v1 is int && v2 is int) {
        if (v1 > v2) {
          return 1;
        }
        else if (v1 < v2) {
          return -1;
        }
      }
      else if (v1 is Node && v2 is int) {
        Node nv2 = Node();
        nv2.isVirtual = true;
        nv2.childs.add(v2);
        var res = checkRecursivelyIfCorrect(v1, nv2);
        if (res != 0) {
          return res;
        }
      }
      else if (v1 is int && v2 is Node) {
        Node nv1 = Node();
        nv1.isVirtual = true;
        nv1.childs.add(v1);
        var res = checkRecursivelyIfCorrect(nv1, v2);
        if (res != 0) {
          return res;
        }
      }
      else if (v1 is Node && v2 is Node) {
        var res = checkRecursivelyIfCorrect(v1, v2);
        if (res != 0) {
          return res;
        }
      }
    }
  }
}

