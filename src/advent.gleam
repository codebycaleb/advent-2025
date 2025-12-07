import days/day01
import days/day02
import days/day03
import days/day04
import days/day05
import gleam/io

pub fn main() -> Nil {
  io.println("Advent of Code 2025")
  day01.solve()
  day02.solve()
  day03.solve()
  day04.solve()
  day05.solve()
  io.println("Done!")
}
