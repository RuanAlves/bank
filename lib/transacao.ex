defmodule Transacao do

  defstruct data: Date.utc_today(), tipo: nil, valor: 0, email_conta_origem: nil, email_conta_destino: nil
  @transacoes "transacoes.txt"

  def gravar(tipo, email_conta_origem, valor, data, email_conta_destino \\ nil) do
    transacoes = busca_transacoes() ++
    [%__MODULE__{tipo: tipo, email_conta_origem: email_conta_origem, valor: valor, data: data, email_conta_destino: email_conta_destino}]
    File.write(@transacoes, :erlang.term_to_binary(transacoes))
  end

  def busca_todas(), do: busca_transacoes()

  defp busca_transacoes() do
    {:ok, binario} = File.read(@transacoes)
    binario
    |> :erlang.binary_to_term()
  end

end
