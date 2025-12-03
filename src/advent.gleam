import days/day01
import days/day02
import gleam/io

pub fn main() -> Nil {
  io.println("Advent of Code 2025")
  day01.solve()
  day02.solve()
  io.println("Done!")
}
