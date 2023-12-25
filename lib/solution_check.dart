mixin SolutionCheck {
  void verifyResult(var actual, var expected) {
    if (actual != expected) {
      throw Exception("Invalid - expected $expected but got $actual");
    }
  }
}
