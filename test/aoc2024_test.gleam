// copied and modified from https://github.com/lpil/gleeunit/blob/8accaa01d4363b917a52f740370558e7ff32e9a0/src/gleeunit.gleam
import gleam/dynamic.{type Dynamic}
import gleam/list
import gleam/result
import gleam/string

pub fn main() -> Nil {
  run_tests()
}

/// Find and run all test functions for the current project using Erlang's EUnit
/// test framework.
///
/// Any Erlang or Gleam function in the given list of files with a name ending in
/// `_test` is considered a test function and will be run.
///
/// If running on JavaScript tests will be run with a custom test runner.
///
fn run_tests() -> Nil {
  let options = [Verbose, NoTty, Report(#(GleeunitProgress, [Colored(True)]))]

  let result =
    find_files(matching: "**/*.{erl,gleam}", in: "src")
    |> list.map(gleam_to_erlang_module_name)
    |> list.map(dangerously_convert_string_to_atom(_, Utf8))
    |> run_eunit(options)
    |> dynamic.result(dynamic.dynamic, dynamic.dynamic)
    |> result.unwrap(Error(dynamic.from(Nil)))

  let code = case result {
    Ok(_) -> 0
    Error(_) -> 1
  }
  halt(code)
}

@external(erlang, "erlang", "halt")
fn halt(a: Int) -> Nil

fn gleam_to_erlang_module_name(path: String) -> String {
  path
  |> string.replace(".gleam", "")
  |> string.replace(".erl", "")
  |> string.replace("/", "@")
}

@external(erlang, "gleeunit_ffi", "find_files")
fn find_files(matching matching: String, in in: String) -> List(String)

type Atom

type Encoding {
  Utf8
}

@external(erlang, "erlang", "binary_to_atom")
fn dangerously_convert_string_to_atom(a: String, b: Encoding) -> Atom

type ReportModuleName {
  GleeunitProgress
}

type GleeunitProgressOption {
  Colored(Bool)
}

type EunitOption {
  Verbose
  NoTty
  Report(#(ReportModuleName, List(GleeunitProgressOption)))
}

@external(erlang, "eunit", "test")
fn run_eunit(a: List(Atom), b: List(EunitOption)) -> Dynamic
