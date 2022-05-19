# Csvala
  Csvala is a CSV parser that specifically looks for duplicate records
  based on email, phone number, or either. The main entry point for the program
  is the parse/2 function, which accepts a file path and a configuration string,
  which can be "e" for email, "p" for phone, or "ep" for either.

  ##Example
    iex> Csvala.parse("my_csv_file.csv", "e)
    :ok

### Installation
  Csvala requires your environment to have Erlang 24+ and Elixir 1.12+. If you do not 
  have them installed already, please follow the excellent steps available at
  https://elixir-lang.org/install.html.

  Once Erlang and Elixir are installed, install the project dependencies with `mix deps.get`, 
  then run the program by starting an IEX session from the Csvala root folder with `iex -S mix`, 
  and entering `Csvala.parse(<your_file_name>, <your_config_selection>), where <your_file_name> 
  is replaced with the relative path of the desired CSV file, and <your_config_selection> is 
  one of "e" for email only, "p" for phone only, or "ep" for either email or phone.

  The deduplicated .csv file will be placed in the same directory as the original, 
  with `_deduplicated_by_` followed by the configuration selection appended to the name.

## Hex and Hexdocs

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `csvala` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:csvala, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/csvala](https://hexdocs.pm/csvala).

