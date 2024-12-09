import day6/board
import gleam/list
import gleam/set
import gleam/string
import solution
import util
import vec

pub fn solution() {
  solution.Solution(
    day: 6,
    example: "
    ....#.....
    .........#
    ..........
    ..#.......
    .......#..
    ..........
    .#..^.....
    ........#.
    #.........
    ......#...",
    part1: fn(input) {
      let input_lines =
        input
        |> string.trim_start
        |> util.lines
        |> list.map(string.trim_start)

      let size =
        vec.of(
          input_lines |> list.first |> util.assert_ok |> string.length,
          input_lines |> list.length,
        )

      let board =
        input_lines
        |> list.index_fold(board.new(size), fn(board, line, y) {
          line
          |> string.trim_start
          |> string.to_graphemes
          |> list.index_fold(board, fn(board, symbol, x) {
            let position = vec.of(x, y)
            case symbol {
              "^" -> board |> board.init_cursor(position, vec.up)
              "<" -> board |> board.init_cursor(position, vec.left)
              ">" -> board |> board.init_cursor(position, vec.right)
              "V" -> board |> board.init_cursor(position, vec.down)
              "#" -> board |> board.add_obstacle(position)
              _ -> board
            }
          })
        })

      board.advance(board).tracks |> set.size
    },
    part2: fn(input) { 0 },
  )
}
