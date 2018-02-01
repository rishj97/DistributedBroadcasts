# Rishabh Jain(rj2315) and Vinamra Agrawal(va1215)
defmodule System6 do
def main() do
    IO.puts ["Eager Reliable Broadcast at ", DNS.my_ip_addr()]
    peer_list = for n <- 0..9 do
        spawn(Peer, :start, [n, self(), 1000, 4000, 50, :infinity])
    end
    peer_pl_list = for _ <- peer_list do
        receive do
            {:pl, peer, pl} -> {peer, pl}
        end
    end

    for {_, pl} <- peer_pl_list do
        send pl, {:broadcast, peer_pl_list}
    end

end

def main_net() do
    IO.puts ["Eager Reliable Broadcast at ", DNS.my_ip_addr()]
    IO.puts "STARTING NOW!!!!"

    peer_list = for n <- 0..9 do
        DAC.node_spawn("peer", n, Peer, :start, [n, self(), 1000, 4000, 50, :infinity])
        # DAC.node_spawn("peer", n, Peer, :start, [])
    end
    peer_pl_list = for _ <- peer_list do
        receive do
            {:pl, peer, pl} -> {peer, pl}
        end
    end

    for {_, pl} <- peer_pl_list do
        send pl, {:broadcast, peer_pl_list}
    end

end
end # module -----------------------
