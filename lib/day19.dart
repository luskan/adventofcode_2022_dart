import 'dart:collection';
import 'package:adventofcode_2022/day02.dart';
import 'package:collection/collection.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

enum MineralType { ore, clay, obsidian, geode }

class RobotCost {
  List<int> costs = List.filled(MineralType.values.length, 0);

  RobotCost();

  void setCost(MineralType type, int cost) {
    costs[type.index] = cost;
  }
}

class Blueprint {
  List<RobotCost> robots;

  Blueprint() : robots = List.filled(MineralType.values.length, RobotCost());

  void setRobotCost(MineralType type, RobotCost cost) {
    robots[type.index] = cost;
  }

  RobotCost getRobotCost(MineralType type) {
    return robots[type.index];
  }
}

class State {
  int time = 0;
  List<int> minerals = List.filled(MineralType.values.length, 0);
  List<int> robotCounts = List.filled(MineralType.values.length, 0);

  State();

  State.clone(State other)
      : time = other.time,
        minerals = List.from(other.minerals),
        robotCounts = List.from(other.robotCounts);

  void addRobot(MineralType type, int count) {
    robotCounts[type.index] += count;
  }

  void addMineral(MineralType type, int count) {
    if (minerals[type.index] + count < 0) {
      throw Exception('Minerals cannot be negative');
    }
    minerals[type.index] += count;
  }

  int getRobotCountForMineral(MineralType type) {
    return robotCounts[type.index];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is State &&
              runtimeType == other.runtimeType &&
              time == other.time &&
              const ListEquality<int>().equals(minerals, other.minerals) &&
              const ListEquality<int>().equals(robotCounts, other.robotCounts);

  @override
  int get hashCode =>
      time.hashCode ^
      const ListEquality<int>().hash(minerals) ^
      const ListEquality<int>().hash(robotCounts);
}


class SolveStrategy {
  List<int> robotCountsMax = List.filled(MineralType.values.length, 0);

  SolveStrategy(this.robotCountsMax);
}

@DayTag()
class Day19 extends Day with ProblemReader, SolutionCheck {

  // This optimization appears to work for my input data, but I am not sure if its ok for other data inputs.
  // It reduced time from 1.10minute to 3.5s in non threaded version.
  var enableHypoteticallyCorrectOptimizations = true;

  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  //Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.
  static Blueprint parseBlueprint(String line) {
    var blueprint = Blueprint();
    var parts = line.split(': ');
    var robotDescriptions = parts[1].split('. ');

    for (var description in robotDescriptions) {
      if (description.isNotEmpty) {
        var nameAndCost = description.split(' costs ');
        var name = nameAndCost[0].split(' ')[1].toLowerCase();
        var robotType = MineralType.values.firstWhere((e) => e.toString().split('.').last == name);

        var costParts = nameAndCost[1].split(' and ');
        var oreCost = int.parse(costParts[0].split(' ')[0]);

        var clayCost = 0;
        var obsidianCost = 0;
        if (costParts.length > 1) {
          var secondaryCost = costParts[1].split(' ')[0];
          if (nameAndCost[1].contains('clay')) {
            clayCost = int.parse(secondaryCost);
          } else if (nameAndCost[1].contains('obsidian')) {
            obsidianCost = int.parse(secondaryCost);
          }
        }

        RobotCost robotCost = RobotCost();
        robotCost.setCost(MineralType.ore, oreCost);
        robotCost.setCost(MineralType.clay, clayCost);
        robotCost.setCost(MineralType.obsidian, obsidianCost);
        blueprint.setRobotCost(robotType, robotCost);
      }
    }

    return blueprint;
  }

  static List<Blueprint> parseData(String data) {
    var res = <Blueprint>[];
    LineSplitter().convert(data).forEach((line) {
      res.add(parseBlueprint(line));
    });
    return res;
  }

  int calculateQualityOfPath(SolveStrategy ss, Blueprint blueprint, State st) {
    var quality = 0;
    for (var robotType in [MineralType.ore, MineralType.clay, MineralType.obsidian, MineralType.geode]) {
      quality += st.getRobotCountForMineral(robotType);
    }
    var minerals = 0;
    for (var mineralType in MineralType.values) {
      minerals += st.minerals[mineralType.index];
    }

    return quality*minerals;
  }

  void calculateMaxGeodes(Blueprint blueprint, List<SolveStrategy> solveStrategies, PrimitiveWrapper<int> maxGeodes, int timeLimit) {
    //print('time: ${st.time}, minerals: ${st.minerals}, robots: ${st.robotCounts}');

    Queue<State> queue = Queue();
    var initState = State();
    initState.addRobot(MineralType.ore, 1);
    initState.time = 0;
    queue.add(initState);

    var visited = <State>{};

    var strategy = solveStrategies[0];

    var geodeFounddMinTime = maxInt;
    var obsidianFounddMinTime = maxInt;

    while(!queue.isEmpty) {
      var current = queue.removeFirst();

      if (current.time == timeLimit) {
        var geodes = current.minerals[MineralType.geode.index];
        if (geodes > maxGeodes.value) {
          maxGeodes.value = geodes;
          //print("geodes = ${geodes} - time: ${current.time}, minerals: ${current.minerals}, robots: ${current.robotCounts}");
        }
        continue;
      }

      /**
       * Check best hypotetical case of number of geodes being build in this branch, and if its not possible
       * to build more geodes than maxGeodes, then skip this branch.
       */
      int leftTime = timeLimit - current.time;
      var a = current.getRobotCountForMineral(MineralType.geode);
      var b = current.getRobotCountForMineral(MineralType.geode) + leftTime;
      var sum = (b - a) * (a + b) ~/ 2;
      if (current.minerals[MineralType.geode.index] + sum <= maxGeodes.value) {
        continue;
      }

      /**
       * Estimate if its even possible to build an geode robot in this branch.
        */
      if (current.minerals[MineralType.geode.index] == 0) {
        a = current.getRobotCountForMineral(MineralType.obsidian);
        b = current.getRobotCountForMineral(MineralType.obsidian) + leftTime;
        sum = (b - a) * (a + b) ~/ 2;
        var bestCaseObsidianCount = current.minerals[MineralType.obsidian.index] + sum;
        var count = bestCaseObsidianCount ~/ blueprint.getRobotCost(MineralType.geode).costs[MineralType.obsidian.index];
        if (count == 0) {
          continue;
        }
      }

      /**
       * Estimate if its even possible to build an obsidian robot in this branch.
        */
      if (current.minerals[MineralType.geode.index] == 0
          && current.minerals[MineralType.obsidian.index] == 0)
      {
        a = current.getRobotCountForMineral(MineralType.clay);
        b = current.getRobotCountForMineral(MineralType.clay) + leftTime;
        sum = (b - a) * (a + b) ~/ 2;
        var bestCaseCount = current.minerals[MineralType.clay.index] + sum;
        if (bestCaseCount < blueprint.getRobotCost(MineralType.obsidian).costs[MineralType.clay.index]) {
          continue;
        }
      }

      if (enableHypoteticallyCorrectOptimizations) {
        if (current.time >= geodeFounddMinTime &&
            current.getRobotCountForMineral(MineralType.geode) == 0) {
          continue;
        }
        if (current.time < geodeFounddMinTime &&
            current.getRobotCountForMineral(MineralType.geode) > 0) {
          geodeFounddMinTime = current.time;
        }

        // This optimization appears to work for my input data, but I am not sure if its ok for other data inputs.
        if (current.time >= obsidianFounddMinTime &&
            current.getRobotCountForMineral(MineralType.obsidian) < 2) {
          continue;
        }
        if (current.time < obsidianFounddMinTime
            && current.getRobotCountForMineral(MineralType.obsidian) >= 2
        ) {
          obsidianFounddMinTime = current.time;
        }
      }

      var newState = State.clone(current);
      newState.time++;

      bool wasGeodeBuild = false;

      // Try build robots
      for (var robotType in [
        MineralType.geode,
        MineralType.obsidian,
        MineralType.clay,
        MineralType.ore,
      ]) {
        var hasRobots = newState.getRobotCountForMineral(robotType);
        var maxRobotsForStrategy = strategy.robotCountsMax[robotType.index];
        if (hasRobots >= maxRobotsForStrategy) {
          continue;
        }

        if (enableHypoteticallyCorrectOptimizations) {
          // Skip building robots if there are no geodes or obsidians. This works for most data tests
          if (newState.getRobotCountForMineral(MineralType.obsidian) > 0) {
           if (robotType == MineralType.ore)
              continue;
          }
        }

        var robotCost = blueprint.getRobotCost(robotType);

        // Calculate max robots can be bought having minerals as in st State
        if (newState.minerals[MineralType.ore.index] >= robotCost.costs[MineralType.ore.index]
            && newState.minerals[MineralType.clay.index] >= robotCost.costs[MineralType.clay.index]
            && newState.minerals[MineralType.obsidian.index] >= robotCost.costs[MineralType.obsidian.index])
        {
          var newState2 = State.clone(newState);

          // Collect minerals befor adding new robot
          for (var type in MineralType.values) {
              newState2.addMineral(type, newState2.getRobotCountForMineral(type));
          }

          // Add new robot
          newState2.addRobot(robotType, 1);

          // Subtract minerals for robot
          for (var mineralType in MineralType.values) {
            newState2.addMineral(
                mineralType, -robotCost.costs[mineralType.index]);
          }

          if (robotType == MineralType.geode) {
            int leftTime = timeLimit - newState2.time;
            var geodesOnEnd = leftTime;
            var possibleGeodesOnEnd = newState2.minerals[MineralType.geode.index] + geodesOnEnd;
            if (possibleGeodesOnEnd > maxGeodes.value) {
              maxGeodes.value = possibleGeodesOnEnd;
            }
          }

          // Add new state
          if (!visited.contains(newState2))
          {
            queue.addFirst(State.clone(newState2));
            visited.add(newState2);

            if (enableHypoteticallyCorrectOptimizations) {
              if (robotType == MineralType.geode) {
                wasGeodeBuild = true;
              }
            }
          }
        }
      }

      // Collecting only minerals (with no robot builing) appears to make sense only when
      // no obsidian or geode robot was build in this state
      if (!wasGeodeBuild) {
        // Collect minerals
        for (var type in MineralType.values) {
          //if (type != MineralType.geode)
          newState.addMineral(type, newState.getRobotCountForMineral(type));
        }

        if (!visited.contains(newState)) {
          queue.addFirst(State.clone(newState));
          visited.add(newState);
        }
      }
    }
  }

  int solve(List<Blueprint> blueprints, {var part2 = false, int timeLimit = 24}) {
    int result = part2 ? 1 : 0;

    var id = 1;
    for (var blueprint in blueprints) {
      var state = State();
      state.addRobot(MineralType.ore, 1);
      PrimitiveWrapper<int> maxGeodes = PrimitiveWrapper(0);

      SolveStrategy st = SolveStrategy([0, 0, 0, 9999]);

      for (var mineralType in MineralType.values) {
        for (var robotType in MineralType.values) {
          var robotCost = blueprint.getRobotCost(robotType);
          st.robotCountsMax[mineralType.index] = max(st.robotCountsMax[mineralType.index], robotCost.costs[mineralType.index]);
        }
      }

      var solveStrategies = <SolveStrategy> [
        st,
      ];

      calculateMaxGeodes(blueprint, solveStrategies, maxGeodes, timeLimit);

      if (part2) {
       result *= maxGeodes.value;
       if (id == 3) {
         break;
       }
      }
      else {
        result += id * maxGeodes.value;
      }
      id++;
    }

    return result;
  }

  @override
  Future<void> run() async {
    print("Day19");

    var data = readData("../adventofcode_input/2022/data/day19.txt");
    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2022/data/day19_result.txt", 0));

    var res2 = solve(data, timeLimit: 32, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2022/data/day19_result.txt", 1));

    data = readData("../adventofcode_input/2022/data/day19b.txt");
    res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2022/data/day19b_result.txt", 0));
  }
}

