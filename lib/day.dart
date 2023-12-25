mixin ProblemReader {}

class DayTag {
  const DayTag();
}

class WorkingOnDayTag {
  const WorkingOnDayTag();
}

abstract class Day {
  Future<void> run() async {
    //await Future.value();
  }
}
