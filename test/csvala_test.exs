defmodule CsvalaTest do
  use ExUnit.Case
  doctest Csvala

  test "greets the world" do
    assert Csvala.hello() == :world
  end
end
