import 'dart:mirrors';
import 'package:adventofcode_2022/day.dart';
import 'package:adventofcode_2022/day01.dart';
import 'package:adventofcode_2022/day02.dart';
import 'package:adventofcode_2022/day03.dart';
import 'package:adventofcode_2022/day04.dart';
import 'package:adventofcode_2022/day05.dart';
import 'package:adventofcode_2022/day06.dart';
import 'package:adventofcode_2022/day07.dart';
import 'package:adventofcode_2022/day08.dart';
import 'package:adventofcode_2022/day09.dart';
import 'package:adventofcode_2022/day10.dart';
import 'package:adventofcode_2022/day11.dart';
import 'package:adventofcode_2022/day12.dart';
import 'package:adventofcode_2022/day13.dart';
import 'package:adventofcode_2022/day14.dart';
import 'package:adventofcode_2022/day15.dart';
import 'package:adventofcode_2022/day16.dart';
import 'package:adventofcode_2022/day17.dart';
import 'package:adventofcode_2022/day18.dart';
import 'package:adventofcode_2022/day19.dart';


import 'dart:developer';
import 'package:worker_manager/worker_manager.dart';

void main(List<String> arguments) async {
  //await Executor().warmUp(log: true);

  var days = <Day>[
    Day01(),
    Day02(),
    Day03(),
    Day04(),
    Day05(),
    Day06(),
    Day07(),
    Day08(),
    Day09(),
    Day10(),
    Day11(),
    Day12(),
    Day13(),
    Day14(),
    Day15(),
    Day16(),
    Day17(),
    Day18(),
    Day19(),
  ];

  for (var day in days) {
    var sw = Stopwatch()..start();
    await day.run();
    print('Profile: ${sw.elapsed.toString()}');
  }

  /*
  // Turned off as it does not alow to await for run method
  MirrorSystem mirrorSystem = currentMirrorSystem();
  mirrorSystem.libraries.forEach((lk, l) {
    l.declarations.forEach((dk, d) {
      if (d is ClassMirror) {
        ClassMirror cm = d as ClassMirror;
        cm.metadata.forEach((md) async {
          InstanceMirror metadata = md as InstanceMirror;
          if (metadata.type == reflectClass(DayTag)) {
            //print('found: ${cm.simpleName}');
            var day = cm.newInstance(Symbol.empty, []);
            var dd = day.reflectee;
            //Timeline.startSync('Profile: ${cm.simpleName}');
            var sw = Stopwatch()..start();
            await dd.run();
            print('Profile: ${sw.elapsed.toString()}');
          }
        });
      }
    });
  });
  */
}
