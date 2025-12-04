import gleam/int
import gleam/list
import utils

const filepath = "inputs/day03.txt"

/// digits([], 42) -> [4, 2]
fn digits(acc: List(Int), x: Int) -> List(Int) {
  case x < 10 {
    True -> [x, ..acc]
    False -> digits([x % 10, ..acc], x / 10)
  }
}

/// undigits([4, 2] -> 42)
fn undigits(acc: List(Int), x: Int) -> Int {
  case acc {
    [hd, ..rest] -> undigits(rest, x * 10 + hd)
    _ -> x
  }
}

/// Selectively inserts n into the front of the list.
/// List only grows in length if n is successfully inserted.
fn insert(list: List(Int), n: Int) {
  case list {
    [hd, ..rest] ->
      case n >= hd {
        // insert([2, 1], 3) -> [3, ..insert([1], 2)] -> [2, ..insert([], 1)] -> [3, 2, 1]
        // insert([1, 2], 3) -> [3, ..insert([2], 1)] -> [3, 2]
        True -> [n, ..insert(rest, hd)]
        // insert([2], 1) -> [2]
        False -> list
      }
    _ -> [n]
  }
}

/// Reduces n from right-to-left, selectively inserting the end digit into acc 
/// (if it would increase the joltage value).
fn max_joltage(acc: List(Int), n: Int) -> List(Int) {
  case n {
    0 -> acc
    _ -> {
      let x = n % 10
      let n = n / 10
      max_joltage(insert(acc, x), n)
    }
  }
}

fn solver(lines: List(Int), num_digits: Int) -> Int {
  lines
  |> list.map(fn(line) {
    // The following bits set up our initial state.
    // Let's take [123456789], 4 as example args.
    // We'd end up calling max_joltage([6, 7, 8, 9], 12345)
    let t = utils.pow10(num_digits)
    let start = digits([], line % t)
    let max = max_joltage(start, line / t)
    // max_joltage can return a list longer than what we passed in
    // so we crop it to the expected length and then repackage it into an int
    max |> list.take(num_digits) |> undigits(0)
  })
  |> int.sum
}

pub fn solve() {
  let lines = utils.parse_lines(filepath, utils.parse_int_or_explode)
  let part1 = solver(_, 2)
  let part2 = solver(_, 12)
  echo part1(lines)
  echo part2(lines)
}
