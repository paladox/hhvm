<?hh

function f($aaaaaaaaaa, $bbbbbbbbbbbbbbbbbbbb, $cccccccccc, $dddddddddd, ...$eee) {
  return function($aaaaaaaaaa, $bbbbbbbbbbbbbbbbbbbb, $cccccccccc, $dddddddddd, ...$eee) { return 1; };
}

class C1 {
  /* Ensure formatting for ellipsis is:
   * string ...$args as opposed to
   * string... $args
  */
  public function meth(string...      $args): void {}
  public function meth2(int $a, int $b,...  $args): void {}
}
