import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import gleam/yielder
import solution.{Solution}
import util

type Point {
  Point(row: Int, col: Int)
}

pub fn solution() {
  Solution(
    day: 4,
    // example: "XMAS",
    example: "....XXMAS.
.SAMXMS...
...S..A...
..A.A.MS.X
XMASAMX.MM
X.....XA.A
S.S.S.S.SS
.A.A.A.A.A
..M.M.M.MM
.X.X.XMASX",
    part1: fn(input) {
      let rows =
        input |> string.trim |> string.split("\n") |> list.map(string.trim)

      let col_count = string.length(rows |> list.first |> util.assert_ok)

      let grid =
        rows
        |> list.index_map(fn(row, row_index) {
          row
          |> string.to_graphemes
          |> list.index_map(fn(letter, col_index) {
            #(Point(row_index, col_index), letter)
          })
        })
        |> list.flatten
        |> dict.from_list

      let horizontal_count =
        yielder.range(0, list.length(rows) - 1)
        |> yielder.fold(0, fn(count, row_index) {
          yielder.range(0, col_count - 4)
          |> yielder.fold(count, fn(count, col_index) {
            let word =
              yielder.range(0, 3)
              |> yielder.map(fn(shift) { Point(row_index, col_index + shift) })
              |> yielder.map(fn(point) {
                case grid |> dict.get(point) {
                  Ok(letter) -> letter
                  Error(..) ->
                    panic as { "unknown point " <> string.inspect(point) }
                }
              })
              |> yielder.to_list
              |> string.concat

            case word {
              "XMAS" | "SAMX" -> {
                io.println("word at " <> string.inspect([row_index, col_index]))
                count + 1
              }
              _ -> count
            }
          })
        })

      let vertical_count =
        yielder.range(0, list.length(rows) - 4)
        |> yielder.fold(0, fn(count, row_index) {
          yielder.range(0, col_count - 1)
          |> yielder.fold(count, fn(count, col_index) {
            let word =
              yielder.range(0, 3)
              |> yielder.map(fn(shift) { Point(row_index + shift, col_index) })
              |> yielder.map(fn(point) {
                case grid |> dict.get(point) {
                  Ok(letter) -> letter
                  Error(..) ->
                    panic as { "unknown point " <> string.inspect(point) }
                }
              })
              |> yielder.to_list
              |> string.concat

            case word {
              "XMAS" | "SAMX" -> {
                io.println("word at " <> string.inspect([row_index, col_index]))
                count + 1
              }
              _ -> count
            }
          })
        })

      let diagonal_count_1 =
        yielder.range(0, list.length(rows) - 4)
        |> yielder.fold(0, fn(count, row_index) {
          yielder.range(0, col_count - 4)
          |> yielder.fold(count, fn(count, col_index) {
            let word =
              yielder.range(0, 3)
              |> yielder.map(fn(shift) {
                Point(row_index + shift, col_index + shift)
              })
              |> yielder.map(fn(point) {
                case grid |> dict.get(point) {
                  Ok(letter) -> letter
                  Error(..) ->
                    panic as { "unknown point " <> string.inspect(point) }
                }
              })
              |> yielder.to_list
              |> string.concat

            case word {
              "XMAS" | "SAMX" -> {
                io.println("word at " <> string.inspect([row_index, col_index]))
                count + 1
              }
              _ -> count
            }
          })
        })

      let diagonal_count_2 =
        yielder.range(0, list.length(rows) - 4)
        |> yielder.fold(0, fn(count, row_index) {
          yielder.range(3, col_count - 1)
          |> yielder.fold(count, fn(count, col_index) {
            let word =
              yielder.range(0, 3)
              |> yielder.map(fn(shift) {
                Point(row_index + shift, col_index - shift)
              })
              |> yielder.map(fn(point) {
                case grid |> dict.get(point) {
                  Ok(letter) -> letter
                  Error(..) ->
                    panic as { "unknown point " <> string.inspect(point) }
                }
              })
              |> yielder.to_list
              |> string.concat

            case word {
              "XMAS" | "SAMX" -> {
                io.println("word at " <> string.inspect([row_index, col_index]))
                count + 1
              }
              _ -> count
            }
          })
        })

      horizontal_count + vertical_count + diagonal_count_1 + diagonal_count_2
    },
    part2: fn(_input) { 0 },
  )
  |> solution.print
}
