import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/set.{type Set}
import gleam/string
import utils

const filepath = "inputs/day07.txt"

type Grid =
  List(Set(Int))

// {-1: count of splits encountered, n: count of paths that get to n}
type Accumulator =
  Dict(Int, Int)

///    ..S..
///    .....
///    ..|..
///    .....
///    .|.|.
///    .....
/// 
/// becomes
/// 
///    [{2},{2},{1,3}]
fn parse(lines: List(String)) -> Grid {
  lines
  |> list.map(fn(line) {
    line
    |> string.to_graphemes
    |> list.index_fold(set.new(), fn(acc, c, x) {
      case c {
        "S" | "^" -> set.insert(acc, x)
        _ -> acc
      }
    })
  })
  |> list.filter(fn(s) { !set.is_empty(s) })
}

/// A dict.upsert function. 
/// If k exists in the dict with value a, this will add value b.
/// Otherwise, this will set k to value b
fn add_or_set(a, b) {
  case a {
    Some(a) -> a + b
    None -> b
  }
}

/// We solve both part 1 and part 2 in a single pass through the grid.
/// 
/// The solution for part 1 is contained within a special key in the Accumulator: -1.  
/// We increment this on each encountered split.
/// 
/// The rest of the entries in the Accumulator are tracking the stream index via the key
/// and how many paths can be taken to get to said stream index.
/// 
///    ...S...
///    ...1...
///    ..1^1..
///    ..1.1..
///    .1^2^1.
///    .1.2.1.
///    1^3^21.
/// 
/// When n is 1, there's exactly 1 path to get there.  
/// n grows to be greater than 1 when multiple paths lead to the same spot 
/// (e.g. the splitters to the left and right of our first 2 in the grid above).  
/// At the end of the grid, we have 1, 3, 2, and 1 as our counts of paths. Summing these
/// will give us the count of unique paths available through the grid (7):
///   - left, left, left     (1)
///   - left, left, right    (2)
///   - left, right, left    (2)
///   - left, right, right   (3)
///   - right, left, left    (2)
///   - right, left, right   (3)
///   - right, right, right  (4)
fn solver(start: set.Set(Int), grid: Grid) -> Accumulator {
  // long-winded way to convert set {n} to dict #{n: 1}
  let assert [start_index] = set.to_list(start)
  let initial: Accumulator = dict.from_list([#(start_index, 1)])

  grid
  |> list.fold(initial, fn(streams: Accumulator, splitters: Set(Int)) {
    // for each of the current streams,
    dict.fold(streams, streams, fn(acc, k, v) {
      // check if the stream gets split in this next row
      case set.contains(splitters, k) {
        True ->
          acc
          // if so, remove that existing stream
          |> dict.delete(k)
          // and add its count of paths to the stream to the left
          |> dict.upsert(k - 1, add_or_set(_, v))
          // and to the stream to the right
          |> dict.upsert(k + 1, add_or_set(_, v))
          // oh, and also increment our special -1 value (which keeps track of splits)
          |> dict.upsert(-1, add_or_set(_, 1))

        // if the stream doesn't get split, ignore it for this row and move on
        False -> acc
      }
    })
  })
}

/// part1 only needs to check the special -1 index value
fn part1(result: Accumulator) -> Int {
  let assert Ok(answer) = dict.get(result, -1)
  answer
}

/// part2 specificially needs to ignore the special -1 index value
/// and then sum all the other values
fn part2(result: Accumulator) -> Int {
  result
  |> dict.delete(-1)
  |> dict.values
  |> int.sum
}

pub fn solve() {
  let assert [start, ..grid] =
    filepath |> utils.read |> string.split("\n") |> parse
  let result = solver(start, grid)
  echo part1(result)
  echo part2(result)
}
