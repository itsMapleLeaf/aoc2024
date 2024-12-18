import gleam/dict
import gleam/list
import gleam/string
import lib/util
import lib/vec

pub opaque type Grid(a) {
  Grid(cells: dict.Dict(vec.Vec, a))
}

pub fn from_string(input: String) -> Grid(String) {
  input
  |> util.lines_trimmed
  |> list.index_map(fn(row, y) {
    row
    |> string.to_graphemes
    |> list.index_map(fn(symbol, x) { #(vec.of(x, y), symbol) })
  })
  |> list.flatten
  |> dict.from_list
  |> Grid
}

pub fn cells(grid: Grid(a)) {
  grid.cells
}

pub fn points(grid: Grid(a)) {
  grid.cells |> dict.keys
}

pub fn values(grid: Grid(a)) {
  grid.cells |> dict.values
}

pub fn at(grid: Grid(a), point: vec.Vec) {
  dict.get(grid.cells, point)
}

pub fn size(grid: Grid(a)) {
  let points = points(grid)
  let min = points |> list.fold(vec.zero, vec.min)
  let max = points |> list.fold(vec.zero, vec.max)
  vec.subtract(max, min) |> vec.add(vec.one)
}

pub fn map_values(grid: Grid(a), with mapper: fn(vec.Vec, a) -> b) -> Grid(b) {
  Grid(dict.map_values(grid.cells, mapper))
}

pub fn filter(
  grid: Grid(a),
  keeping predicate: fn(vec.Vec, a) -> Bool,
) -> Grid(a) {
  Grid(dict.filter(grid.cells, predicate))
}

pub fn contains_point(grid: Grid(a), point: vec.Vec) {
  let size = size(grid)
  point.x >= 0 && point.x < size.x && point.y >= 0 && point.y < size.y
}
