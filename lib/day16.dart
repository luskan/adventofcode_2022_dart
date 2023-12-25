import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:adventofcode_2022/common.dart';

import 'day.dart';
import 'solution_check.dart';

/**
 * Solution inspired by https://github.com/frhel/AdventOfCode/blob/master/2022/day_16
 */

class Path {
  String startValve, endValve; // Start and end valve names
  int steps;                  // Number of steps in the path, actually its pathSequence.length-1
  double weight;              // Weight of the path
  int flow;                   // Flow rate
  List<String> pathSequence;  // Sequence of valves from start to end

  Path(this.startValve, this.endValve, this.steps, this.weight, this.flow, this.pathSequence);
}

class PathElem {
  String nextValve, currentValve;

  PathElem(this.nextValve, this.currentValve);
}

class Node {
  String name;
  int flow;
  List<String> tunnels;
  List<Path> paths = [];
  double maxWeight = 0;

  Node(this.name, this.flow, this.tunnels);
}

class QueueElement {
  Node node;
  List<String> visited = [];
  int steps = 0, flowRate = 0, flow = 0, totalFlow = 0;
  double priority = 0.0;

  QueueElement(this.node, this.visited, this.steps, this.flowRate, this.flow, this.totalFlow, this.priority);
}

@DayTag()
class Day16 extends Day with ProblemReader, SolutionCheck {
  static const String startNodeName = "AA";

  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static List<Node> parseData(var data) {
    List<Node> valves = [];

    LineSplitter().convert(data).forEach((line) {
      if (line.isEmpty)
        return;

      //Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
      //Valve HH has flow rate=22; tunnel leads to valve GG
      var matches = RegExp(r'^Valve (?<name>[A-Z]+) has flow rate=(?<flow>\d+); tunnels? leads? to valves? (?<tunnels>.+)$').allMatches(line);

      var match = matches.elementAt(0);
      var name = match.namedGroup("name") ?? "";
      var flow = int.parse(match.namedGroup("flow") ?? "");
      var tunnels = (match.namedGroup("tunnels") ?? "").split(',').map((e) => e.trim()).toList();

      valves.add(Node(name, flow, tunnels));
    });

    for (var valve in valves) {
        valve.paths = calculateShortestPathsUsingBFS(valves, valve.name);
        valve.paths.forEach((element) {
          element.flow = valve.flow * (element.steps + 1);
        });
        valve.paths.sort((a, b) => a.weight.compareTo(b.weight));
        valve.maxWeight = valve.paths.last.weight;
      }
    valves.removeWhere((element) => element.flow <= 0 && element.name != startNodeName);
    valves.sort((a, b) => b.maxWeight.compareTo(a.maxWeight));

    return valves;
  }

  String getNodeNames(List<Node> nodes) {
    return "["+nodes.map((e) => e.name).join(',')+"]";
  }

  int solve(List<Node> valvesData, {var part2 = false, int maxRounds = 30}) {
    var startNode = valvesData.where((element) => element.name==startNodeName).first;

    if (!part2) {
      return findBestPath(valvesData, startNode, part2: part2, maxRounds: maxRounds);
    }

    valvesData.removeWhere((element) => element.name == startNodeName);
    int splitCount = valvesData.length ~/ 2;
    int splitMod = valvesData.length % 2;
    var splits = combinations(valvesData, splitCount + splitMod);

    var splitsCombined = splits.map((split) {
      var remaining = List<Node>.from(valvesData)
        ..removeWhere((valve) => split.contains(valve));
      return [split, remaining];
    }).toList();

    final List<int> bestFlow = List.filled(splitsCombined.length, 0);
    for (var i = 0; i < splitsCombined.length; i++) {
      var split = splitsCombined[i];
      var f1 = findBestPath(split[0], startNode, part2: part2, maxRounds: maxRounds);
      var f2 = findBestPath(split[1], startNode, part2: part2, maxRounds: maxRounds);
      //if (i < 500) {
      //  print ('i: f1:${getNodeNames(split[0])}');
      //  print ('i: f2:${getNodeNames(split[1])}');
      //  print('i: $i f1: $f1 f2: $f2');
      //}
      bestFlow[i] = f1 + f2;
    }
    bestFlow.sort((a, b) => b.compareTo(a));

    return bestFlow[0];
  }

  int findBestPath(List<Node> valvesData, Node startNode, {bool part2 = false, int maxRounds = 30}) {
    Queue<QueueElement> queue = Queue();
    queue.add(QueueElement(startNode, [], 0, 0, 0, 0, 0));

    var winner = queue.first;
    while (queue.isNotEmpty) {
      var current = queue.removeFirst();

      current.visited.add(current.node.name);

      if (current.totalFlow > winner.totalFlow) {
        winner = QueueElement(current.node, current.visited, current.steps, current.flowRate, current.flow, current.totalFlow, current.priority);
      }

      for (var valve in valvesData) {
        if (valve.name == current.node.name || valve.flow == 0) continue;

        var edge = current.node.paths.firstWhere((element) => element.endValve == valve.name);
        var steps = current.steps + (edge.steps + 1);
        if (current.visited.contains(valve.name) || steps > maxRounds) continue;

        var flow = current.flowRate * (edge.steps + 1) + current.flow;
        var flowRate = current.flowRate + valve.flow;
        var totalFlow = flowRate * (maxRounds - steps) + flow;

        var v1 = edge.flow * (maxRounds / valvesData.length) / 2.4;
        var priority = (current.totalFlow + totalFlow).toDouble() - v1;

        if (priority <= winner.priority) break;

        queue.add(QueueElement(valve, [...current.visited], steps, flowRate, flow, totalFlow, priority));
      }
    }

    return winner.totalFlow;
  }

  // Function to calculate the shortest paths from a start node to all other nodes using Breadth-First Search (BFS).
  static List<Path> calculateShortestPathsUsingBFS(List<Node> nodes, String start) {
    var shortestPaths = <Path>[]; // Holds the shortest paths found
    var queue = Queue<String>(); // Queue for BFS
    var pathElements = <PathElem>[], visited = <String>[]; // To track the path and visited nodes

    for (var targetNode in nodes.where((node) => node.name != start && node.flow != 0)) {

      queue.clear();
      queue.add(start);
      pathElements.clear();
      visited.clear();

      while (queue.isNotEmpty) {
        var currentNodeName = queue.removeFirst();
        var currentNode = nodes.firstWhere((node) => node.name == currentNodeName);

        // Check if the current node leads directly to the target node
        if (currentNode.tunnels.contains(targetNode.name)) {
          var path = [currentNodeName, targetNode.name];
          while (pathElements.isNotEmpty) {
            var element = pathElements.removeLast();
            if (element.nextValve == currentNodeName) {
              path.insert(0, element.currentValve);
              currentNodeName = element.currentValve;
            }
          }

          // Add the found path to the list
          shortestPaths.add(Path(
              start,
              targetNode.name,
              path.length - 1,
              targetNode.flow / path.length.toDouble(),
              0,
              path));
          break;
        }

        // Explore adjacent nodes
        currentNode.tunnels.where((tunnel) => !visited.contains(tunnel)).forEach((tunnel) {
          pathElements.add(PathElem(tunnel, currentNodeName));
          queue.add(tunnel);
        });
        visited.add(currentNodeName); // Mark the node as visited
      }
    }

    return shortestPaths; // Return the list of shortest paths
  }

  @override
  Future<void> run() async {
    print("Day16");

    var data = readData("../adventofcode_input/2022/data/day16.txt");
    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2022/data/day16_result.txt", 0));

    data = readData("../adventofcode_input/2022/data/day16.txt");
    var res2 = solve(data, part2: true, maxRounds: 26);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2022/data/day16_result.txt", 1));
  }
}

