# Rishabh Jain(rj2315) and Vinamra Agrawal(va1215)
defmodule System6 do
def main() do
    init_system(:local)
end

def main_net() do
    init_system(:docker)
end

defp init_system(env) do
    IO.puts ["Eager Reliable Broadcast at ", DNS.my_ip_addr()]
    reliability = 100
    peer_list = for n <- 0..4 do
        timeout = cond do
            n == 3 -> 200
            true -> 3000
        end
        case env do
            :local ->
                spawn(Peer, :start, [n, self(), 1000, timeout, reliability])
            :docker ->
                DAC.node_spawn("peer", n, Peer, :start, [n, self(), 1000, timeout, reliability])
        end
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
