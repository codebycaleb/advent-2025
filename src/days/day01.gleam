import gleam/int
import gleam/list
import gleam/pair
import utils

const filepath = "inputs/day01.txt"

type Direction {
  Left
  Right
}

type Turn {
  Turn(direction: Direction, steps: Int)
}

fn parse_line(line: String) -> Turn {
  case line {
    "L" <> steps_str -> {
      case int.parse(steps_str) {
        Ok(steps) -> Turn(Left, steps)
        Error(_) -> panic
      }
    }
    "R" <> steps_str -> {
      case int.parse(steps_str) {
        Ok(steps) -> Turn(Right, steps)
        Error(_) -> panic
      }
    }
    _ -> {
      panic as "Couldn't parse line. Check inputs/day01.txt."
    }
  }
}

/// Normalize n to be within 0-99
/// -1 -> 99; 100 -> 0; 101 -> 1
fn normalize(n: Int) -> Int {
  { 100 + n } % 100
}

fn part1(turns: List(Turn)) -> Int {
  // list.scan will output the position after each turn
  list.scan(over: turns, from: 50, with: fn(acc, turn) {
    case turn {
      Turn(Left, steps) -> acc - steps
      Turn(Right, steps) -> acc + steps
    }
    |> normalize
  })
  // then we just count how many times we hit 0
  |> list.count(where: fn(n) { n == 0 })
}

fn part2(turns: List(Turn)) -> Int {
  // list.map_fold will output a pair of (final position, list of zero hits per turn)
  list.map_fold(over: turns, from: 50, with: fn(acc, turn) {
    // R314 can be broken down into 3 full rotations and 14 steps.
    let full_rotations = turn.steps / 100
    let reduced_steps = turn.steps % 100

    // Perform the turn (only using the reduced steps since we've already counted full rotations).
    let n = case turn.direction {
      Left -> acc - reduced_steps
      Right -> acc + reduced_steps
    }

    // Count if we "hit" 0 after the turn.
    let zero_hits = case acc {
      // If we start at 0, this wasn't "hitting" 0.
      0 -> 0
      _ ->
        case n {
          // However, if we land at 0 (or pass it), we count that as a hit.
          x if x <= 0 -> 1
          x if x >= 100 -> 1
          _ -> 0
        }
    }

    // #(new position, total zero hits this turn)
    #(normalize(n), full_rotations + zero_hits)
  })
  // pair.second is the list of zero hits per turn
  |> pair.second
  |> int.sum()
}

pub fn solve() {
  let turns = utils.parse(filepath, parse_line)
  echo part1(turns)
  echo part2(turns)
}
