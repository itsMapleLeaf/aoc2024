import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import gleam/yielder
import solution.{Solution}
import util

pub fn solution() {
  Solution(
    day: 4,
    // example: "XMAS",
    example: "MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX",
    part1: fn(input) {
      let rows =
        input |> string.trim |> string.split("\n") |> list.map(string.trim)

      let result =
        rows
        |> list.index_fold(
          SearchState(completions: [], found: 0),
          fn(state, letters, row) {
            letters
            |> string.to_graphemes
            |> list.index_fold(state, fn(state, letter, col) {
              io.println("---")
              io.debug(
                state.completions
                |> list.filter(fn(c) { c.direction == Diagonal }),
              )
              io.debug(letter)
              io.debug([row, col])

              let completions =
                state.completions
                // remove dead completions
                |> list.filter(fn(comp) { !is_dead(comp, row, col) })
                // advance matching completions
                |> list.map(fn(comp) {
                  case
                    is_current(comp, row, col)
                    && is_desired_letter(comp, letter)
                  {
                    True -> advance_completion(comp)
                    False -> comp
                  }
                })

              // count finished completions
              let finished_count = list.count(completions, is_finished)

              // remove finished completions
              let completions =
                completions |> list.filter(fn(comp) { !is_finished(comp) })

              // start new completions for word beginnings
              let new_completions = case letter {
                "X" ->
                  [Horizontal, Vertical, Diagonal]
                  |> list.map(fn(direction) {
                    let #(next_row, next_col) =
                      next_position(direction, row, col)
                    Completion(
                      word: "XMAS",
                      progress: 0,
                      direction:,
                      next_row:,
                      next_col:,
                    )
                  })
                "S" ->
                  [Horizontal, Vertical, Diagonal]
                  |> list.map(fn(direction) {
                    let #(next_row, next_col) =
                      next_position(direction, row, col)
                    Completion(
                      word: "SAMX",
                      progress: 0,
                      direction:,
                      next_row:,
                      next_col:,
                    )
                  })
                _ -> []
              }

              SearchState(
                found: state.found + finished_count,
                completions: list.flatten([completions, new_completions]),
              )
            })
          },
        )

      result.found
    },
    part2: fn(_input) { 0 },
  )
  |> solution.print
}

type SearchState {
  SearchState(completions: List(Completion), found: Int)
}

type Completion {
  Completion(
    word: String,
    progress: Int,
    direction: Direction,
    next_row: Int,
    next_col: Int,
  )
}

type Direction {
  Horizontal
  Vertical
  Diagonal
}

fn next_position(direction: Direction, row: Int, col: Int) {
  case direction {
    Horizontal -> #(row, col + 1)
    Vertical -> #(row + 1, col)
    Diagonal -> #(row + 1, col + 1)
  }
}

fn desired_letter(completion: Completion) {
  completion.word
  |> string.drop_start(completion.progress + 1)
  |> string.first
  |> util.assert_ok
}

fn is_dead(completion: Completion, row: Int, col: Int) {
  row > completion.next_row && col > completion.next_col
}

fn is_current(completion: Completion, row: Int, col: Int) {
  row == completion.next_row && col == completion.next_col
}

fn is_desired_letter(completion: Completion, letter: String) {
  letter == desired_letter(completion)
}

fn is_finished(completion: Completion) {
  completion.progress == string.length(completion.word) - 1
}

fn advance_completion(completion: Completion) {
  let #(next_row, next_col) =
    next_position(
      completion.direction,
      completion.next_row,
      completion.next_col,
    )
  Completion(
    ..completion,
    progress: completion.progress + 1,
    next_row:,
    next_col:,
  )
}
