# Rishabh Jain(rj2315) and Vinamra Agrawal(va1215)

defmodule BEB do

def start(peer, rb) do
    IO.puts ["      BEB at ", DNS.my_ip_addr()]
    receive do
        {:broadcast, pl, peer_pl_list} ->
            send rb, {:broadcast, self(), peer_pl_list}
            next(peer, pl, rb, peer_pl_list)
    end
end

defp next(peer, pl, rb, peer_pl_list) do
    receive do
        {:beb_broadcast, msg} ->
            # Broadcast message received from app to all known peers
            for {peer_to, _} <- peer_pl_list do
                send pl, {:pl_send, peer_to, msg}
            end
            next(peer, pl, rb, peer_pl_list)
        {:pl_deliver, peer_from, msg} ->
            send rb, {:beb_deliver, peer_from, msg}
            next(peer, pl, rb, peer_pl_list)
    end
end

end # module -----------------------
