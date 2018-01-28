# Rishabh Jain(rj2315)

defmodule Peer do

def start(num) do
  IO.puts ["      Peer at ", DNS.my_ip_addr()]
  receive do
  { :bind, peers } -> wait_for_broadcast(num, peers)
  end
end

defp wait_for_broadcast(num, peers) do
    peer_data = for peer <- peers, do: {peer, {0,0}}
  receive do
      { :broadcast, max_messages, timeout } ->
          broadcast(peer_data, max_messages, cur_time() + timeout, num)
  end
end

defp broadcast(peer_data, num_left, end_time, my_num) do
    cond do
        cur_time() >= end_time ->
            print_result(my_num, peer_data)
        num_left > 0 ->
            receive do
                {:broadcast_msg, peer_from} ->
                    peer_data = receive_broadcast(peer_from, peer_data)
                    broadcast(peer_data, num_left, end_time, my_num)
            after
                0 ->
                    peer_data = send_broadcast(peer_data)
                    broadcast(peer_data, num_left - 1, end_time, my_num)
            end
        true ->
            receive do
                {:broadcast_msg, peer_from} ->
                    peer_data = receive_broadcast(peer_from, peer_data)
                    broadcast(peer_data, num_left, end_time, my_num)
            after
                0 -> broadcast(peer_data, num_left, end_time, my_num)
            end
    end
end

defp print_result(num, peer_data) do
    str = for {_, stats} <- peer_data do
        " #{inspect(stats)}"
    end
    str = ["#{num}:"] ++ str
    IO.puts str
end

defp send_broadcast(peer_data) do
    for {peer, {sent, received}} <- peer_data do
        send peer, {:broadcast_msg, self()}
        {peer, {sent + 1, received}}
    end
end

defp receive_broadcast(peer_from, peer_data) do
    {_, {num_sent, num_received}} = List.keyfind(peer_data, peer_from, 0, nil)
    List.keyreplace(
        peer_data, peer_from, 0, {peer_from, {num_sent, num_received + 1}})
end

defp cur_time() do
    :os.system_time(:millisecond)
end
end # module -----------------------
