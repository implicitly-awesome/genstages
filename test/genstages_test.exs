defmodule GSTest do
  use ExUnit.Case
  doctest GS

  test "greets the world" do
    assert GS.hello() == :world
  end
end
