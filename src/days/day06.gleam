import gleam/int
import gleam/list
import gleam/string
import utils

const filepath = "inputs/day06.txt"

/// "*  +  *" -> [int.multiply, int.add, int.multiply]
fn parse_ops(ops_line: String) -> List(fn(Int, Int) -> Int) {
  ops_line
  |> string.split(" ")
  |> list.fold([], fn(acc, c) {
    case c {
      "" -> acc
      "+" -> [int.add, ..acc]
      "*" -> [int.multiply, ..acc]
      _ -> panic as "unexpected ops input!"
    }
  })
  |> list.reverse
}

/// [["12  3"],["45  6"]] -> [[12,45],[3,6]]]
fn parse1(lines: List(String)) -> #(List(List(Int)), List(fn(Int, Int) -> Int)) {
  let assert [ops_line, ..args_lines] = list.reverse(lines)
  let ops = parse_ops(ops_line)
  let args =
    args_lines
    |> list.map(fn(line) {
      line
      // "12  3" -> ["12","","3"]
      |> string.split(" ")
      // parse_int_or_explode will explode on empty strings
      |> list.filter(fn(s) { !string.is_empty(s) })
      // ["12","3"] -> [12,3]
      |> list.map(utils.parse_int_or_explode)
    })
    // [[12,3],[45,6]] -> [[12,45],[3,6]]
    |> list.transpose
  #(args, ops)
}

/// [["12 3"],["45 6"]] -> [[14,25],[36]]]
fn parse2(lines: List(String)) -> #(List(List(Int)), List(fn(Int, Int) -> Int)) {
  let assert [ops_line, ..args_lines] = list.reverse(lines)
  let ops = parse_ops(ops_line)
  let args =
    args_lines
    |> list.reverse
    // "12 3" -> ["1","2"," "," ","3"]
    |> list.map(string.to_graphemes)
    // [["1","2"," ","3"],["4","5"," ","6"]] -> 
    // [["1","4"],["2","5"],[" "," "],["3","6"]]
    |> list.transpose
    // ["1","4"] -> "14"
    // [" "," "] -> "  "
    |> list.map(string.join(_, ""))
    // "  " -> ""
    |> list.map(string.trim)
    // ["14","25","","36"] -> [["14","25"],[""],["36"]]
    |> list.chunk(string.is_empty)
    // [["14","25"],[""],["36"]] -> [["14","25"],["36"]]
    |> list.filter(fn(col) { list.length(col) > 1 })
    // [["14","25"],["36"]] -> [[14,25],[36]]
    |> list.map(list.map(_, utils.parse_int_or_explode))
  #(args, ops)
}

fn solver(args: List(List(Int)), ops: List(fn(Int, Int) -> Int)) {
  args
  |> list.zip(ops, _)
  |> list.map(fn(col) {
    let #(op, args) = col
    let assert Ok(result) = list.reduce(args, op)
    result
  })
  |> int.sum
}

pub fn solve() {
  let input = filepath |> utils.read() |> string.split("\n")
  let #(args, ops) = parse1(input)
  echo solver(args, ops)
  let #(args, ops) = parse2(input)
  echo solver(args, ops)
}
