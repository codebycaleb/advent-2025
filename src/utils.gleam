import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn lines(path: String) -> List(String) {
  path
  |> simplifile.read()
  |> result.unwrap("Could not read file at " <> path)
  |> string.split("\n")
}

pub fn parse(path: String, with: fn(String) -> a) -> List(a) {
  lines(path)
  |> list.map(with)
}
