import gleam/float
import gleam/int
import gleam/yielder.{type Yielder}

pub type Vec {
  Vec(x: Int, y: Int)
}

pub const zero = Vec(0, 0)

pub const one = Vec(1, 1)

pub const left = Vec(-1, 0)

pub const right = Vec(1, 0)

pub const up = Vec(0, -1)

pub const down = Vec(0, 1)

pub fn of(x: Int, y: Int) -> Vec {
  Vec(x:, y:)
}

pub fn get_x(vec: Vec) {
  vec.x
}

pub fn get_y(vec: Vec) {
  vec.y
}

pub fn add(a: Vec, b: Vec) -> Vec {
  of(a.x + b.x, a.y + b.y)
}

pub fn subtract(a: Vec, b: Vec) -> Vec {
  of(a.x - b.x, a.y - b.y)
}

pub fn multiply(a: Vec, b: Vec) -> Vec {
  of(a.x * b.x, a.y * b.y)
}

pub fn divide(a: Vec, b: Vec) -> Vec {
  of(a.x / b.x, a.y / b.y)
}

pub fn scale(vec: Vec, factor: Int) -> Vec {
  of(vec.x * factor, vec.y * factor)
}

pub fn unscale(vec: Vec, factor: Int) -> Vec {
  of(vec.x / factor, vec.y / factor)
}

pub fn points_within_range(from start: Vec, to end: Vec) -> Yielder(Vec) {
  yielder.flat_map(yielder.range(start.x, end.x), fn(x) {
    yielder.map(yielder.range(start.y, end.y), fn(y) { of(x, y) })
  })
}

pub fn distance(a: Vec, b: Vec) -> Result(Float, Nil) {
  let dx = a.x - b.x
  let dy = a.y - b.y
  { dx * dx + dy * dy }
  |> int.to_float
  |> float.square_root
}

pub fn min(a: Vec, b: Vec) -> Vec {
  of(int.min(a.x, b.x), int.min(a.y, b.y))
}

pub fn max(a: Vec, b: Vec) -> Vec {
  of(int.max(a.x, b.x), int.max(a.y, b.y))
}

pub fn normalize_corners(a: Vec, b: Vec) {
  #(min(a, b), max(a, b))
}

pub fn rotate_right(vec: Vec) {
  of(vec.y * -1, vec.x)
}
