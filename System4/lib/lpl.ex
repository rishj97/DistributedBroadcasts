# Rishabh Jain(rj2315)
defmodule LPL do
    def start(peer, beb, reliability) do
        IO.puts ["      PL at ", DNS.my_ip_addr()]
        receive do
            {:broadcast, peer_pl_list} ->
                send beb, {:broadcast, self(), peer_pl_list}
                start_listening(peer, peer_pl_list, beb, reliability)
        end
    end

    defp start_listening(peer, peer_pl_list, beb, reliability) do
        receive do
            {:pl_send, peer_to, seq_no} ->
                {_, pl} = List.keyfind(peer_pl_list, peer_to, 0, nil)
                cond do
                    DAC.random(100) <= reliability ->
                        send pl, {:broadcast_msg, peer, seq_no}
                    true ->
                        nil
                end
            {:broadcast_msg, peer_from, seq_no} ->
                send beb, {:pl_deliver, peer_from, seq_no}
        end
        start_listening(peer, peer_pl_list, beb, reliability)
    end
end # module -----------------------
