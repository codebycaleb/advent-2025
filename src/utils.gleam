import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn read(path: String) -> String {
  path
  |> simplifile.read()
  |> result.unwrap("Could not read file at " <> path)
}

pub fn parse(
  path: String,
  with: fn(String) -> a,
  split_by substring: String,
) -> List(a) {
  read(path)
  |> string.split(substring)
  |> list.map(with)
}

pub fn parse_lines(path: String, with: fn(String) -> a) -> List(a) {
  parse(path, with, "\n")
}

/// pow10(6) -> 1_000_000
pub fn pow10(n: Int) -> Int {
  case n {
    x if x <= 0 -> 1
    _ -> pow10(n - 1) * 10
  }
}

pub fn parse_int_or_explode(s: String) -> Int {
  let assert Ok(n) = int.parse(s) as "AHHH!!! BAD INPUT!!"
  n
}
