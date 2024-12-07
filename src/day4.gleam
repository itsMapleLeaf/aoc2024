import gleam/dict
import gleam/int
import gleam/list
import gleam/string
import solution.{Solution}

type Position {
  Position(row: Int, col: Int)
}

type Pattern =
  List(PatternSymbol)

type PatternSymbol {
  PatternSymbol(letter: String, offset: Position)
}

fn pattern_from_string(input: String) -> Pattern {
  input
  |> parse_symbol_grid
  |> dict.to_list
  |> list.filter(fn(entry) { entry.1 != " " })
  |> list.map(fn(entry) {
    let #(position, letter) = entry
    PatternSymbol(letter, position)
  })
}

fn position_sum(a: Position, b: Position) {
  Position(a.row + b.row, a.col + b.col)
}

fn symbol(letter: String, row_offset: Int, col_offset: Int) {
  PatternSymbol(letter, Position(row_offset, col_offset))
}

fn flip_pattern_letters(pattern: Pattern) {
  list.map2(pattern, pattern |> list.reverse, fn(base, flipped) {
    PatternSymbol(..base, letter: flipped.letter)
  })
}

type Grid =
  dict.Dict(Position, String)

fn parse_symbol_grid(input: String) {
  input
  |> string.trim
  |> string.split("\n")
  // |> list.map(string.trim)
  |> list.index_map(fn(row_content, row_index) {
    row_content
    |> string.to_graphemes
    |> list.index_map(fn(letter, col_index) {
      #(Position(row_index, col_index), letter)
    })
  })
  |> list.flatten
  |> dict.from_list
}

fn check_pattern(pattern: Pattern, in grid: Grid, at anchor: Position) {
  pattern
  |> list.all(fn(pattern_symbol) {
    let grid_letter =
      grid |> dict.get(position_sum(anchor, pattern_symbol.offset))

    case grid_letter {
      Error(_) -> False
      Ok(letter) -> letter == pattern_symbol.letter
    }
  })
}

fn count_pattern_matches(of patterns: List(Pattern), in grid: Grid) {
  patterns
  |> list.map(fn(pattern) {
    grid
    |> dict.keys
    |> list.count(check_pattern(pattern, in: grid, at: _))
  })
  |> int.sum
}

pub fn solution() {
  Solution(
    day: 4,
    example: ".M.S......
..A..MSMS.
.M.S.MAA..
..A.ASMSM.
.M.S.M....
..........
S.S.S.S.S.
.A.A.A.A..
M.M.M.M.M.
..........",
    part1: fn(input) {
      let patterns: List(Pattern) = [
        [
          symbol("X", 0, 0),
          symbol("M", 1, 0),
          symbol("A", 2, 0),
          symbol("S", 3, 0),
        ],
        [
          symbol("X", 0, 0),
          symbol("M", 0, 1),
          symbol("A", 0, 2),
          symbol("S", 0, 3),
        ],
        [
          symbol("X", 0, 0),
          symbol("M", 1, 1),
          symbol("A", 2, 2),
          symbol("S", 3, 3),
        ],
        [
          symbol("X", 0, 3),
          symbol("M", 1, 2),
          symbol("A", 2, 1),
          symbol("S", 3, 0),
        ],
      ]

      // make inverse versions of the patterns
      let patterns =
        patterns
        |> list.append(list.map(patterns, flip_pattern_letters))

      let grid = parse_symbol_grid(input)

      patterns |> count_pattern_matches(in: grid)
    },
    part2: fn(input) {
      let patterns: List(Pattern) = [
        pattern_from_string(string.join(["M S", " A ", "M S"], "\n")),
        pattern_from_string(string.join(["M M", " A ", "S S"], "\n")),
        pattern_from_string(string.join(["S M", " A ", "S M"], "\n")),
        pattern_from_string(string.join(["S S", " A ", "M M"], "\n")),
      ]

      let grid = parse_symbol_grid(input)

      patterns |> count_pattern_matches(in: grid)
    },
  )
}
