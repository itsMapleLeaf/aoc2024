import gleam/dict
import gleam/list
import gleam/yielder
import lib/solution.{Solution}
import lib/symbol_grid
import lib/vec

pub fn solution() {
  Solution(
    day: 8,
    example: "
    ............
    ........0...
    .....0......
    .......0....
    ....0.......
    ......A.....
    ............
    ............
    ........A...
    .........A..
    ............
    ............",
    part1: fn(input) {
      let grid = input |> symbol_grid.from_string
      grid
      |> antenna_pair_groups
      |> get_antinode_points
      |> count_valid_unique_locations(grid)
    },
    part2: fn(input) {
      let grid = input |> symbol_grid.from_string
      grid
      |> antenna_pair_groups
      |> get_extended_antinode_points(grid)
      |> count_valid_unique_locations(grid)
    },
  )
}

fn antenna_pair_groups(grid: symbol_grid.SymbolGrid) {
  grid
  |> symbol_grid.cells
  |> list.filter(fn(entry) { entry.1 != "." })
  |> list.group(fn(entry) { entry.1 })
  |> dict.values
  |> list.map(fn(symbol_entries) {
    let pairs =
      symbol_entries
      |> list.map(fn(entry) { entry.0 })
      |> list.combination_pairs

    pairs
    |> list.append(pairs |> list.map(fn(pair) { #(pair.1, pair.0) }))
  })
}

fn get_antinode_points(antenna_pair_groups: List(List(#(vec.Vec, vec.Vec)))) {
  antenna_pair_groups
  |> list.flat_map(fn(pairs) {
    list.map(pairs, fn(pair) { vec.subtract(pair.1, pair.0) |> vec.add(pair.1) })
  })
}

fn get_extended_antinode_points(
  antenna_pair_groups: List(List(#(vec.Vec, vec.Vec))),
  grid: symbol_grid.SymbolGrid,
) {
  antenna_pair_groups
  |> list.flat_map(fn(pairs) {
    list.flat_map(pairs, fn(pair) {
      let interval = vec.subtract(pair.1, pair.0)
      yielder.iterate(pair.0, vec.add(_, interval))
      |> yielder.take_while(symbol_grid.contains_point(grid, _))
      |> yielder.to_list
    })
  })
}

fn count_valid_unique_locations(
  list: List(vec.Vec),
  grid: symbol_grid.SymbolGrid,
) {
  list
  |> list.unique
  |> list.count(symbol_grid.contains_point(grid, _))
}
