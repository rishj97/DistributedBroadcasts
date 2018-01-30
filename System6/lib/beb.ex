# Rishabh Jain(rj2315)

defmodule BEB do

def start(peer, rb) do
    IO.puts ["      BEB at ", DNS.my_ip_addr()]
    receive do
        {:broadcast, pl, peer_pl_list} ->
            send rb, {:broadcast, self(), peer_pl_list}
            start_listening(peer, pl, rb, peer_pl_list)
    end
end

defp start_listening(peer, pl, rb, peer_pl_list) do
    receive do
        {:beb_broadcast, peer_from, seq_no} ->
            for {peer_to, _} <- peer_pl_list do
                send pl, {:pl_send, peer_from, peer_to, seq_no}
            end
            start_listening(peer, pl, rb, peer_pl_list)
        {:pl_deliver, peer_from, seq_no} ->
            send rb, {:beb_deliver, peer_from, seq_no}
            start_listening(peer, pl, rb, peer_pl_list)
    end
end

end # module -----------------------
