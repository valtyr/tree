defmodule Tree do
  def hidden?(item) do
    !String.starts_with?(item, ".")
  end

  def describe_item(item, dir) do
    full_path = Path.join(dir, item)
    case File.dir?(full_path) do
      false -> {:file, item}
      true -> {:folder, item}
    end
  end

  def pipe(is_last) do
    case is_last do
      false -> "├── "
      true -> "└── "
    end
  end

  def tree_postfix(is_last) do
    case is_last do
      true -> "    "
      false -> "│   "
    end
  end

  def sort_key_extractor(item) do
    case item do
      {:file, name} -> "file:" <> name
      {:folder, name} -> "folder:" <> name
    end
  end

  def dir_list(dir \\ ".", tree \\ "") do
    item_describer = fn item -> describe_item(item, dir) end

    items = Enum.filter(File.ls!(dir), fn item -> hidden?(item) end)
    |> Enum.map(item_describer)
    |> Enum.sort_by(&sort_key_extractor/1)
    |> Enum.with_index

    for {{type, item}, i} <- items do
      is_last = length(items) - 1 == i
      IO.puts tree <> pipe(is_last) <> item

      if type == :folder do
        next_tree = tree <> tree_postfix(is_last)
        dir_list(Path.join(dir, item), next_tree)
      end
    end
  end

  def print do
    IO.puts "."
    dir_list()
  end
end

Tree.print

