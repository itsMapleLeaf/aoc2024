import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/set.{type Set}
import gleam/string
import solution.{Solution}
import util
import vec.{type Vec}

pub type Board {
  Board(
    size: Vec,
    position: Vec,
    direction: Vec,
    obstacles: Set(Vec),
    tracks: Set(Vec),
  )
}

pub fn new(size: Vec) {
  Board(
    size:,
    position: vec.zero,
    direction: vec.zero,
    obstacles: set.new(),
    tracks: set.new(),
  )
}

pub fn init_cursor(board: Board, position: Vec, direction: Vec) {
  board
  |> set_position(position)
  |> set_direction(direction)
}

pub fn set_position(board: Board, position: Vec) {
  Board(..board, position:, tracks: set.insert(board.tracks, position))
}

pub fn set_direction(board: Board, direction: Vec) {
  Board(..board, direction:)
}

pub fn add_obstacle(board: Board, position: Vec) {
  Board(
    ..board,
    obstacles: set.union(board.obstacles, set.from_list([position])),
  )
}

pub fn advance(board: Board) -> Board {
  let next_position = board.position |> vec.add(board.direction)
  case board.obstacles |> set.contains(next_position) {
    True ->
      board
      |> set_direction(board.direction |> vec.rotate_right)
      |> advance

    False ->
      case is_out_of_bounds(board, next_position) {
        True -> board
        False -> board |> set_position(next_position) |> advance
      }
  }
}

pub fn is_out_of_bounds(board: Board, position: Vec) {
  position.x < 0
  || position.y < 0
  || position.x >= board.size.x
  || position.y >= board.size.y
}
