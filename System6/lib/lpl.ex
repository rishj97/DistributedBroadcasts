# Rishabh Jain(rj2315) and Vinamra Agrawal(va1215)
defmodule LPL do
def start(peer, beb, reliability) do
    IO.puts ["      PL at ", DNS.my_ip_addr()]
    receive do
        {:broadcast, peer_pl_list} ->
            send beb, {:broadcast, self(), peer_pl_list}
            next(peer, peer_pl_list, beb, reliability, [])
    end
end

defp next(peer, peer_pl_list, beb, reliability, received_msgs) do
    receive do
        {:pl_send, peer_from, peer_to, seq_no, msg} ->
            {_, pl} = List.keyfind(peer_pl_list, peer_to, 0, nil)
            cond do
                DAC.random(100) <= reliability ->
                    send pl, { :pl_deliver, peer_from, seq_no, msg }
                true ->
                    nil
            end
            next(peer, peer_pl_list, beb, reliability, received_msgs)
        {:pl_deliver, peer_from, seq_no, msg} ->
            cond do
                Enum.member?(received_msgs, {peer_from, seq_no}) ->
                    next(peer, peer_pl_list, beb, reliability, received_msgs)
                true ->
                    send beb, {:pl_deliver, peer_from, seq_no, msg}
                    next(peer, peer_pl_list, beb, reliability, received_msgs ++ [{peer_from, seq_no}])
            end
    end

end
end # module -----------------------
