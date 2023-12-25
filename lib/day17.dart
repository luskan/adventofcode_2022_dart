import 'dart:io';
import 'dart:math';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

class Rock {
  int type;
  int x;
  int y;
  Rock(this.x, this.y, this.type);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Rock &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => type.hashCode ^ x.hashCode ^ y.hashCode;
}

class WindStart {
  int height;
  int rockType;
  int rocksCount;

  WindStart(this.height, this.rockType, this.rocksCount);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WindStart &&
          runtimeType == other.runtimeType &&
          height == other.height &&
          rocksCount == other.rocksCount &&
          rockType == other.rockType;

  @override
  int get hashCode => height.hashCode ^ rockType.hashCode ^ rocksCount.hashCode;
}

class FoundCycle {
  int cycleLen;
  int cycleStart;
  int cycleEnd;

  FoundCycle(this.cycleLen, this.cycleStart, this.cycleEnd);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoundCycle &&
          runtimeType == other.runtimeType &&
          cycleLen == other.cycleLen &&
          cycleStart == other.cycleStart &&
          cycleEnd == other.cycleEnd;

  @override
  int get hashCode => cycleLen.hashCode ^ cycleStart.hashCode ^ cycleEnd.hashCode;

  @override
  String toString() {
    return 'FoundCycle{cycleLen: $cycleLen, cycleStart: $cycleStart, cycleEnd: $cycleEnd}';
  }
}

enum CollisionType {
  none, walls, ground
}

/// Circular list implementation
class CircularList<T> {
  List<T> _internalList;
  int _size;

  CircularList.filled(int size, T fillValue)
      : _size = size,
        _internalList = List<T>.filled(size, fillValue);

  CircularList.from(CircularList<T> other)
      : _size = other._size,
        _internalList = List<T>.from(other._internalList);

  T operator [](int index) {
    return _internalList[index % _size];
  }

  void operator []=(int index, T value) {
    _internalList[index % _size] = value;
  }

  int get length => _size;
}

@DayTag()
class Day17 extends Day with ProblemReader, SolutionCheck {

  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static final windLeft = 0;
  static final windRight = 1;
  static final goingDown = 3;

  static List<int> parseData(String data) {
    return data.split('').where((e) => e != '\n').map((e){
      if (e == '<') {
        return windLeft;
      }
      else if (e == '>') {
        return windRight;
      }
      throw Exception("Unknown char $e");
    }).toList();
  }

  var rockTypes = [
"####",

'''.#.
###
.#.''',

'''..#
..#
###''',

'''#
#
#
#''',

'''##
##'''
  ];

  late List<List<String>> splitRocks;
  int chamberWidth = 7;

  /// Returns true if cycle is found. It tries various sizes starting from the right
  /// side. In tests it appears that it was not necessary as cycle is found
  /// after few full iterations of wind array.
  bool isCycleFound(List<WindStart> chamber, FoundCycle foundCycle) {
    // Get the length of the chamber
    int len = chamber.length;

    // Loop through the chamber starting from the middle to the beginning
    for (int cycleLen = len ~/ 2; cycleLen >= 1; cycleLen--) {
      bool cycleFound = true;

      // Check if the current rock type is the same as the rock type cycleLen steps before
      for (int i = len - cycleLen; i < len; i++) {
        if (chamber[i].rockType != chamber[i - cycleLen].rockType) {
          cycleFound = false;
          break;
        }
      }

      // If a cycle is found, update the foundCycle object and return true
      if (cycleFound) {
        foundCycle.cycleLen = cycleLen;
        foundCycle.cycleStart = len - cycleLen;
        foundCycle.cycleEnd = len-1;
        return true;
      }
    }

  // If no cycle is found, return false
  return false;
}

  int solve(List<int> wind, {var part2 = false, int part2RocksToThrow = 2022}) {
    splitRocks = rockTypes.map((rock) => rock.split('\n')).toList();

    int windCounter = 0;
    int height = 0;
    var fallenRocks = <Rock>[];
    var chamber = CircularList<bool>.filled(chamberWidth*550, false);
    var pattern = <WindStart>[];
    for (var rockCount = 0; rockCount < part2RocksToThrow; ++rockCount) {

      var type = rockCount % rockTypes.length;
      var rock = Rock(2, height + 3 + (splitRocks[type].length - 1), type);

      for (var n = height*chamberWidth; n < ((height+8)*chamberWidth); ++n) {
        chamber[n] = false;
      }

      fallenRocks.add(rock);
      CollisionType collisionType;

      while(true) {
        int prevX = rock.x;
        int prevY = rock.y;

        // In part 2 I check for cycles, they appear preety quikly. I assume that a cycle is
        // when the full wind array was processed, then I store in pattern array the rock type that is about to be
        // thrown. On each cycle I check if the pattern in rock types repeats. If it does, I calculate the result.

        if (part2) {
          if ((windCounter % wind.length) == 0 && rockCount > 0) {
            pattern.add(WindStart(height, type, rockCount));
            var foundCycle = FoundCycle(0, 0, 0);
            if (isCycleFound(pattern, foundCycle)) {

              // Cycle found, calculate the result. We
              // need to calculate how many full cycles
              // we have and how many rocks are left
              // after that. Then we need to calculate
              // the height of the last rock.

              // On each cycle, how much height increases
              var cycleHeight = pattern[foundCycle.cycleEnd].height - pattern[foundCycle.cycleStart-1].height;

              // On each cycle, how many rocks are thrown
              var cycleRocksCount = pattern[foundCycle.cycleEnd].rocksCount - pattern[foundCycle.cycleStart-1].rocksCount;

              // How many full cycles we have
              var fullCyclesTotal = part2RocksToThrow ~/ cycleRocksCount;

              // What is the height of all the full cycles
              var fullCyclesHeight = fullCyclesTotal * cycleHeight;

              // Now to the result
              int result = fullCyclesHeight;

              // How many rocks are left after full cycles
              var remainingRocks = part2RocksToThrow % cycleRocksCount;
              result += fallenRocks[remainingRocks].y;

              return result;
            }
          }
        }

        // First wind
        int windDirection = wind[(windCounter++)%wind.length];
        if (windDirection == windLeft) {
          rock.x--;
        }
        else if (windDirection == windRight) {
          rock.x++;
        }
        collisionType = isColliding(rock, chamber);
        if (collisionType != CollisionType.none) {
          rock.x = prevX;
        }

        // Then falling
        rock.y--;
        //printChamberWidthRock(chamber, rock);
        collisionType = isColliding(rock, chamber);
        if (collisionType != CollisionType.none) {
          rock.y = prevY;
          writeRockToChamber(rock, chamber);
          height = max(height, rock.y + 1);
          break;
        }
      }
    }

    return height;
  }

  /// Prints chamber with rock
  /// Only for debugging
  void printChamberWidthRock(CircularList<bool> chamber, Rock rock) {
    // make copy of chamber
    var chamberCopy = CircularList<bool>.from(chamber);
    writeRockToChamber(rock, chamberCopy, debug: true);
    var maxLines = 10;
    for (var y = maxLines; y >= 0; --y) {
      for (var x = 0; x < chamberWidth; ++x) {
        var chamberIndex = y * chamberWidth + x;
        var chamberValue = chamberCopy[chamberIndex];
        if (chamberValue == false) {
          stdout.write('.');
        }
        else if (chamberValue) {
          stdout.write('#');
        }
        //else {
        //  stdout.write('@');
        //}
      }
      stdout.write('\n');
    }
    stdout.write('\n');
  }

  /// Returns true if rock is colliding with chamber or other rocks
  CollisionType isColliding(Rock rock, CircularList<bool> chamber) {
    var rockType = rockTypes[rock.type];
    var rockLines = splitRocks[rock.type];
    var rockHeight = rockLines.length;
    var rockWidth = rockLines[0].length;
    var rockBottom = rock.y - rockHeight;
    var rockRight = rock.x + rockWidth;
    var rockLeft = rock.x;
    var rockTop = rock.y;

    if (rock.y < 0 || rockBottom < -1) {
      return CollisionType.ground;
    }

    if (rockLeft + rockWidth > chamberWidth) {
      return CollisionType.walls;
    }
    if (rockLeft < 0) {
      return CollisionType.walls;
    }

    for (var y = rockTop; y > rockBottom; --y) {
      for (var x = rockLeft; x < rockRight; ++x) {
        if (rockLines[rockTop - y][x - rockLeft] == '.') {
          continue;
        }
        var chamberIndex = y * chamberWidth + x;
        if (chamber[chamberIndex]) {
          return CollisionType.ground;
        }
      }
    }

    return CollisionType.none;
  }

  /// Writes rock to chamber
  void writeRockToChamber(Rock rock, CircularList<bool> chamber, {bool debug = false}) {
    var rockLines = splitRocks[rock.type];
    var rockHeight = rockLines.length;
    var rockWidth = rockLines[0].length;
    var rockBottom = rock.y - rockHeight;
    var rockRight = rock.x + rockWidth;
    var rockLeft = rock.x;
    var rockTop = rock.y;

    for (var y = rockTop; y > rockBottom; --y) {
      for (var x = rockLeft; x < rockRight; ++x) {
        if (rockLines[rockTop - y][x - rockLeft] == '.') {
          continue;
        }
        if (y < 0) {
          continue;
        }
        var chamberIndex = y * chamberWidth + x;
        chamber[chamberIndex] = true;
      }
    }
  }

  @override
  Future<void> run() async {
    print("Day17");

    var data = readData("../adventofcode_input/2022/data/day17.txt");
    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2022/data/day17_result.txt", 0));

    data = readData("../adventofcode_input/2022/data/day17.txt");
    var res2 = solve(data, part2: true, part2RocksToThrow: 1000000000000);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2022/data/day17_result.txt", 1));
  }
}

