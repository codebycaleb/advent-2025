import gleam/int
import gleam/list
import gleam/string
import utils

const filepath = "inputs/day05.txt"

type Range {
  Range(start: Int, end: Int)
}

fn in_range(n: Int, range: Range) {
  range.start <= n && n <= range.end
}

fn parse(ranges_raw: String, ids_raw: String) -> #(List(Range), List(Int)) {
  let ranges =
    ranges_raw
    |> string.split("\n")
    |> list.map(fn(line) {
      case string.split(line, "-") {
        [a, b] ->
          Range(utils.parse_int_or_explode(a), utils.parse_int_or_explode(b))
        _ -> panic as "Bad input! Check inputs/days05.txt"
      }
    })
  let ids =
    ids_raw |> string.split("\n") |> list.map(utils.parse_int_or_explode)
  #(ranges, ids)
}

/// Sorts the ranges and combines them when possible
/// e.g. [(1,4),(2,3),(5,6),(9,10)] -> [(1,6),(9,10)]
fn optimize_ranges(ranges: List(Range)) -> List(Range) {
  ranges
  |> list.sort(fn(a, b) { int.compare(a.start, b.start) })
  |> list.fold([], fn(acc: List(Range), r) {
    case acc {
      [] -> [r]
      [hd, ..rest] ->
        case hd.end >= r.start - 1 {
          // had a frustrating bug where I always used r.end and that was not the right call lol
          True -> [Range(hd.start, int.max(hd.end, r.end)), ..rest]
          False -> [r, ..acc]
        }
    }
  })
}

fn part1(ranges: List(Range), ids: List(Int)) -> Int {
  ids
  |> list.filter(fn(id) { list.any(ranges, in_range(id, _)) })
  |> list.length()
}

fn part2(ranges: List(Range)) -> Int {
  ranges
  |> list.map(fn(range) { range.end - range.start + 1 })
  |> int.sum
}

pub fn solve() {
  let input = utils.read(filepath)
  let #(ranges, ids) = case string.split(input, "\n\n") {
    [ranges_raw, ids_raw] -> parse(ranges_raw, ids_raw)
    _ -> panic as "Bad input! Check inputs/days05.txt"
  }
  let ranges = optimize_ranges(ranges)
  echo part1(ranges, ids)
  echo part2(ranges)
}
