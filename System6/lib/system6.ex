# Rishabh Jain(rj2315)
defmodule System6 do
def main() do
    IO.puts ["PL broadcast at ", DNS.my_ip_addr()]
    peer_list = for n <- 0..4 do
        ttl = cond do
            n == 3 -> 5
            true -> :infinity
        end
        spawn(Peer, :start, [n, self(), 1000, 4000, 100, ttl])
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
