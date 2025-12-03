import gleam/list
import gleam/result
import gleam/string
import simplifile

fn read(path: String) -> String {
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
