# Rishabh Jain(rj2315) and Vinamra Agrawal(va1215)

defmodule BEB do

def start(app) do
    IO.puts ["      BEB at ", DNS.my_ip_addr()]
    receive do
        {:broadcast, pl, peer_pl_list} ->
            send app, {:broadcast, self(), peer_pl_list}
            next(pl, app, peer_pl_list)
    end
end

defp next(pl, app, peer_pl_list) do
    receive do
        {:beb_broadcast, msg} ->
            for {peer, _} <- peer_pl_list do
                send pl, {:pl_send, peer, msg}
            end
        {:pl_deliver, peer_from, msg} ->
            send app, {:beb_deliver, peer_from, msg}
    end
    next(pl, app, peer_pl_list)
end

end # module -----------------------
