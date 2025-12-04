import gleam/int
import gleam/list
import gleam/set
import gleam/string
import utils

const filepath = "inputs/day02.txt"

type Range {
  Range(start: Int, end: Int)
}

fn parse_range(range_str: String) -> Range {
  case string.split_once(range_str, "-") {
    Ok(#(left, right)) -> {
      let assert Ok(start) = int.parse(left)
      let assert Ok(end) = int.parse(right)
      Range(start, end)
    }
    Error(Nil) -> panic as "Couldn't parse line. Check inputs/day02.txt."
  }
}

/// The list of ints that cleanly divide n (excluding n itself).
/// divisors(6) -> [1, 2, 3]
fn divisors(n: Int) -> List(Int) {
  list.range(1, n - 1) |> list.filter(fn(x) { n % x == 0 })
}

/// The list of all repeating patterns for a given digit length.
/// complex_patterns(5) -> [11111, 22222, ..., 99999]
/// complex_patterns(6) -> [100100, 101010, 101101, ..., 989898, ..., 998998, 999999]
fn complex_patterns(digits: Int) -> List(Int) {
  divisors(digits)
  |> list.flat_map(fn(q) {
    // (6,1) -> 111111;  (6,2) -> 101010, 111111, 121212..; (6,3) -> 100100, 101101, ...
    let pattern = { utils.pow10(digits) - 1 } / { utils.pow10(q) - 1 }
    // 1 -> 1..9, 2 -> 10..99, 3 -> 100..999
    let range = list.range(utils.pow10(q - 1), utils.pow10(q) - 1)
    list.map(range, int.multiply(_, pattern))
  })
}

/// A subset of complex_patterns where only NN patterns are allowed.
/// double_patterns(5) -> []
/// double_patterns(6) -> [100100, 101101, ..., 998998, 999999]
fn double_patterns(digits: Int) -> List(Int) {
  case digits % 2 {
    // odd digits aren't allowed
    1 -> []
    _ -> {
      let q = digits / 2
      // the rest of this is directly copied from complex_patterns.
      // we only care about the case where we repeat half the digits twice
      // (e.g. 101101 is okay but 101010 is not)
      let pattern = { utils.pow10(digits) - 1 } / { utils.pow10(q) - 1 }
      let range = list.range(utils.pow10(q - 1), utils.pow10(q) - 1)
      list.map(range, int.multiply(_, pattern))
    }
  }
}

/// The steps to solve parts 1 and 2 are the same; they just care about different sets of patterns.
/// (e.g. 101010 is valid for part 2 but not for part 1; 101101 is valid for both.)
fn solver(ranges: List(Range), pattern_generator: fn(Int) -> List(Int)) -> Int {
  let assert Ok(max) =
    ranges |> list.map(fn(r) { r.end }) |> list.max(int.compare)
  let p =
    list.range(2, 10)
    |> list.flat_map(pattern_generator)
    // trims the size of our set for faster checking later
    |> list.filter(fn(x) { x <= max })
    |> set.from_list

  ranges
  |> list.flat_map(fn(range) {
    list.range(range.start, range.end)
    |> list.filter(fn(n) { set.contains(p, n) })
  })
  |> int.sum
}

pub fn solve() {
  let ranges = utils.parse(filepath, parse_range, ",")
  let part1 = solver(_, double_patterns)
  let part2 = solver(_, complex_patterns)
  echo part1(ranges)
  echo part2(ranges)
}
