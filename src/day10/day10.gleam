import gleam/int
import gleam/list
import lib/grid
import lib/solution.{Solution}
import lib/util
import lib/vec

const example_input = "
89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732"

pub fn solution() {
  Solution(day: 10, example: example_input, part1:, part2:)
}

type Map =
  grid.Grid(Int)

fn parse_map(input) {
  input
  |> grid.from_string
  |> grid.map_values(fn(_, value) {
    let assert Ok(value) = int.parse(value)
    value
  })
}

fn part1(input: String) {
  input
  |> parse_map
  |> sum_trailhead_scores
}

fn sum_trailhead_scores(map: Map) {
  let trailheads =
    map
    |> grid.filter(fn(_, height) { height == 0 })
    |> grid.points

  let peaks =
    map
    |> grid.filter(fn(_, height) { height == 9 })
    |> grid.points

  util.list_map_sum(trailheads, fn(trailhead_point) {
    list.count(peaks, has_gradual_path(map, trailhead_point, _))
  })
}

fn has_gradual_path(map: Map, point: vec.Vec, peak_point: vec.Vec) {
  case point == peak_point {
    True -> True
    False -> {
      case map |> grid.at(point) {
        Error(_) -> False
        Ok(height) -> {
          list.any(vec.cardinals, fn(dir) {
            let next_point = vec.add(point, dir)
            case map |> grid.at(next_point) {
              Ok(next_height) if next_height == height + 1 -> {
                has_gradual_path(map, next_point, peak_point)
              }
              _ -> False
            }
          })
        }
      }
    }
  }
}

fn part2(input: String) {
  input
  |> parse_map
  |> sum_trailhead_ratings
}

fn sum_trailhead_ratings(map: Map) {
  let trailheads =
    map
    |> grid.filter(fn(_, height) { height == 0 })
    |> grid.points

  let peaks =
    map
    |> grid.filter(fn(_, height) { height == 9 })
    |> grid.points

  util.list_map_sum(trailheads, fn(trailhead_point) {
    util.list_map_sum(peaks, count_paths(map, trailhead_point, _))
  })
}

fn count_paths(map: Map, point: vec.Vec, peak_point: vec.Vec) -> Int {
  case point == peak_point {
    True -> 1
    False -> {
      case map |> grid.at(point) {
        Error(_) -> 0
        Ok(height) -> {
          util.list_map_sum(vec.cardinals, fn(dir) {
            let next_point = vec.add(point, dir)
            case map |> grid.at(next_point) {
              Ok(next_height) if next_height == height + 1 -> {
                count_paths(map, next_point, peak_point)
              }
              _ -> 0
            }
          })
        }
      }
    }
  }
}
