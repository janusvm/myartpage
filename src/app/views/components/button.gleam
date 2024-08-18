import gleam/string
import lustre/attribute as a
import lustre/element.{type Element} as e
import lustre/element/html as h

pub fn submit_button(text: String, classes: List(String)) -> Element(a) {
  let class =
    [
      "flex",
      "w-full",
      "justify-center",
      "rounded-md",
      "bg-pink-600",
      "px-3",
      "py-1.5",
      "text-sm",
      "font-semibold",
      "leading-6",
      "text-white",
      "shadow-sm",
      "hover:bg-pink-500",
      "focus-visible:outline",
      "focus-visible:outline-2",
      "focus-visible:outline-offset-2",
      "focus-visible:outline-pink-600",
      ..classes
    ]
    |> string.join(" ")

  h.button([a.type_("submit"), a.class(class)], [e.text(text)])
}
