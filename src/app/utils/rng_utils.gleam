import gleam/result
import gleam/string
import prng/random

const numerics = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

const letters = [
  "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P",
  "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f",
  "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v",
  "w", "x", "y", "z",
]

const alphanumerics = [
  "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P",
  "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f",
  "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v",
  "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
]

fn random_string(length: Int, alphabet: List(String)) -> String {
  random.try_uniform(alphabet)
  |> result.unwrap(random.constant(""))
  |> random.fixed_size_list(length)
  |> random.random_sample()
  |> string.join("")
}

pub fn random_numerics(length: Int) -> String {
  random_string(length, numerics)
}

pub fn random_letters(length: Int) -> String {
  random_string(length, letters)
}

pub fn random_alphanumerics(length: Int) -> String {
  random_string(length, alphanumerics)
}
