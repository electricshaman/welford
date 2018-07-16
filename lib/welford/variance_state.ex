defmodule Welford.VarianceState do
  defstruct count: 0, mean: 0.0, m2: 0.0

  alias __MODULE__

  @opaque t :: %VarianceState{count: integer, mean: float, m2: float}

  @spec new() :: t
  def new do
    %VarianceState{}
  end

  @spec new(integer, float, float) :: t
  def new(count, mean, m2) do
    %VarianceState{count: count, mean: mean, m2: m2}
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(var_state, opts) do
      concat([
        "#VarianceState<",
        Inspect.Integer.inspect(var_state.count, opts),
        ", ",
        Inspect.Float.inspect(var_state.mean, opts),
        ">"
      ])
    end
  end
end
