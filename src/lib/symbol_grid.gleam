import gleam/int
import gleam/list
import gleam/string
import lib/util
import lib/vec

pub opaque type SymbolGrid {
  SymbolGrid(lines: List(String))
}

pub fn from_string(input: String) {
  SymbolGrid(input |> util.lines_trimmed)
}

pub fn width(grid: SymbolGrid) {
  grid.lines |> list.map(string.length) |> list.fold(0, int.max)
}

pub fn height(grid: SymbolGrid) {
  grid.lines |> list.length
}

pub fn cells(grid: SymbolGrid) {
  grid.lines
  |> list.index_map(fn(row, y) {
    row
    |> string.to_graphemes
    |> list.index_map(fn(symbol, x) { #(vec.of(x, y), symbol) })
  })
  |> list.flatten
}

pub fn contains_point(grid: SymbolGrid, point: vec.Vec) {
  point.x >= 0
  && point.x < width(grid)
  && point.y >= 0
  && point.y < height(grid)
}
