defmodule Conta do

  defstruct usuario: Usuario, saldo: 1000
  @contas "contas.txt"

  def cadastrar_teste(usuario) do
    #File.write("transacoes.txt", :erlang.term_to_binary([]))
      binary = [%__MODULE__{usuario: usuario}]
      |> :erlang.term_to_binary()
      File.write(@contas, binary)
  end

  def cadastrar(usuario) do
    case buscar_por_email(usuario.email) do
      nil ->
        binary = [%__MODULE__{usuario: usuario}] ++ buscar_contas()
        |> :erlang.term_to_binary()
        File.write(@contas, binary)
      _ ->
        {:error, "Conta já cadastrada"}
    end
  end

  def buscar_contas do
    {:ok, binary} = File.read(@contas)
    :erlang.binary_to_term(binary)
  end

  def deletar(contas_deletar) do
    Enum.reduce(contas_deletar, buscar_contas(), fn c, acc -> List.delete(acc, c) end)
  end

  def buscar_por_email(email) do
    Enum.find(buscar_contas(), fn c -> c.usuario.email == email end)
  end

  def transferir(email_conta_origem, email_conta_destino, valor) do
    conta_origem = buscar_por_email(email_conta_origem)
    conta_destino = buscar_por_email(email_conta_destino)

    cond do
      valida_saldo(conta_origem.saldo, valor) ->
          {:error, "Saldo insuficiente"}
      true ->
          contas = Conta.deletar([conta_origem, conta_destino])
          conta_origem = %Conta{conta_origem | saldo: conta_origem.saldo - valor}
          conta_destino = %Conta{conta_destino | saldo: conta_destino.saldo + valor}
          contas = contas ++ [conta_origem, conta_destino]
          Transacao.gravar("transferencia", conta_origem.usuario.email, valor, Date.utc_today(), conta_destino.usuario.email)
          File.write(@contas, :erlang.term_to_binary(contas))
    end

  end

  def sacar(conta, valor) do
    cond do
      valida_saldo(conta.saldo, valor) ->
        {:error, "Saldo insuficiente"}
      true ->
        contas = buscar_contas()
        contas = List.delete(contas, conta)

        conta = %Conta{conta | saldo: conta.saldo - valor}
        contas = contas ++ [conta]
        File.write(@contas, :erlang.term_to_binary(contas))
        {:ok, conta, "Mensagem de email encaminhada"}
    end
  end

  defp valida_saldo(saldo, valor), do: saldo < valor

end
