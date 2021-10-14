defmodule LogParser.Parser do
  def parse(string) do
    {:nomatch, nil, string}
    |> check(:warning)
    |> check(:error)
  end

  defp check({:match, _, _} = input, _), do: input

  defp check({:nomatch, nil, string}, :warning) do
    if string =~ ~r{ModSecurity: Warning} do
      {:match, :warning, string}
    else
      {:nomatch, nil, string}
    end
  end

  defp check({:nomatch, nil, string}, :error) do
    if string =~ ~r{Anomaly Score Exceeded} do
      {:match, :error, string}
    else
      {:nomatch, nil, string}
    end
  end
end
