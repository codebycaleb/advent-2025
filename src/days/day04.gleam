import gleam/function
import gleam/list
import gleam/set
import gleam/string
import utils

const filepath = "inputs/day04.txt"

type Grid =
  set.Set(#(Int, Int))

/// Parses the grid string into a dict of {#(x, y), 0}
/// (where #(0, 0) is the first character from the first line)
fn parse_grid(lines: List(String)) -> Grid {
  lines
  |> list.index_map(fn(line, y) {
    // "..@.@"
    line
    // [".", ".", "@", ".", "@"]
    |> string.to_graphemes
    |> list.index_fold([], fn(acc, c, x) {
      case c {
        // [#(4, 0), ..[#(2, 0)]]
        "@" -> [#(x, y), ..acc]
        _ -> acc
      }
    })
  })
  |> list.flatten
  |> set.from_list
}

/// Takes #(x, y) and returns the 8 adjacent neighbors.
fn neighbors(pair: #(Int, Int)) -> List(#(Int, Int)) {
  let #(x, y) = pair
  [
    #(x - 1, y - 1),
    #(x, y - 1),
    #(x + 1, y - 1),
    #(x + 1, y),
    #(x + 1, y + 1),
    #(x, y + 1),
    #(x - 1, y + 1),
    #(x - 1, y),
  ]
}

/// Filters the items in the grid to the subset of items that are removable.
fn removable_paper(grid: Grid) -> Grid {
  grid
  |> set.filter(fn(k) {
    k
    |> neighbors
    |> list.filter(set.contains(grid, _))
    |> list.length
    < 4
  })
}

fn part1(grid: Grid) -> Int {
  removable_paper(grid)
  |> set.size
}

fn part2(grid: Grid) -> Int {
  let original_size = set.size(grid)
  let final_size = grid |> part2_loop |> set.size
  original_size - final_size
}

fn part2_loop(grid: Grid) -> Grid {
  let removable = removable_paper(grid)
  case set.is_empty(removable) {
    True -> grid
    False -> removable |> set.difference(grid, _) |> part2_loop
  }
}

pub fn solve() {
  let input = utils.parse_lines(filepath, function.identity)
  let grid = parse_grid(input)
  echo part1(grid)
  echo part2(grid)
}
