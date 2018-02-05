# Rishabh Jain(rj2315) and Vinamra Agrawal(va1215)
defmodule App do
def start(my_num, max_messages, timeout) do
    IO.puts ["      App at ", DNS.my_ip_addr()]
    receive do
        {:broadcast, pl, peer_pl_list} ->
            peer_data = for {peer, _} <- peer_pl_list, do: {peer, {0,0}}
            broadcast(peer_data, max_messages, cur_time() + timeout, my_num, pl)
    end
end

defp broadcast(peer_data, broadcasts_left, end_time, my_num, pl) do
    cond do
        cur_time() >= end_time ->
            stop_broadcasting(my_num, peer_data)
        broadcasts_left > 0 ->
            receive do
                {:pl_deliver, peer_from, :broadcast_msg} ->
                    peer_data = receive_broadcast(peer_from, peer_data)
                    broadcast(peer_data, broadcasts_left, end_time, my_num, pl)
            after
                # Incase nothing to be received
                0 ->
                    peer_data = send_broadcast(peer_data, pl)
                    broadcast(peer_data, broadcasts_left - 1, end_time, my_num, pl)
            end
        true ->
            # Keep listening until timeout
            receive do
                {:pl_deliver, peer_from, :broadcast_msg} ->
                    peer_data = receive_broadcast(peer_from, peer_data)
                    broadcast(peer_data, broadcasts_left, end_time, my_num, pl)
            after
                # Recursive call to recheck timeout
                0 -> broadcast(peer_data, broadcasts_left, end_time, my_num, pl)
            end
    end
end

defp stop_broadcasting(num, peer_data) do
    # Display results
    str = for {_, stats} <- peer_data do
        " #{inspect(stats)}"
    end
    str = ["#{num}:"] ++ str
    IO.puts str
end

defp send_broadcast(peer_data, pl) do
    for {peer, {num_sent, num_received}} <- peer_data do
        send pl, {:pl_send, peer, :broadcast_msg}
        {peer, {num_sent + 1, num_received}}
    end
end

defp receive_broadcast(peer_from, peer_data) do
    {_, {num_sent, num_received}} = List.keyfind(peer_data, peer_from, 0, nil)
    List.keyreplace(
        peer_data, peer_from, 0, {peer_from, {num_sent, num_received + 1}})
end

# Returns current time in milliseconds
defp cur_time() do
    :os.system_time(:millisecond)
end
end # module -----------------------
