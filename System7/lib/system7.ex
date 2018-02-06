# Rishabh Jain(rj2315) and Vinamra Agrawal(va1215)
defmodule System7 do
def main() do
    init_system(:local)
end

def main_net() do
    init_system(:docker)
end

defp init_system(env) do
    IO.puts ["Lazy Reliable Broadcast at ", DNS.my_ip_addr()]
    reliability = 100
    fd_delay = 1000
    peer_list = for n <- 0..4 do
        timeout = cond do
            n == 3 -> 2000
            true -> 30000
        end
        case env do
            :local ->
                spawn(Peer, :start, [n, self(), 10000000, timeout, reliability, fd_delay])
            :docker ->
                DAC.node_spawn("peer", n, Peer, :start, [n, self(), 1000, timeout, reliability, fd_delay])
        end
    end
    peer_pls_list = for _ <- peer_list do
        receive do
            {:pls, peer, pl1, pl2} -> {peer, {pl1, pl2}}
        end
    end
    peer_pl1_list = for {peer, {pl1, _}} <- peer_pls_list do
        {peer, pl1}
    end
    peer_pl2_list = for {peer, {_, pl2}} <- peer_pls_list do
        {peer, pl2}
    end
    for {_, {pl1, pl2}} <- peer_pls_list do
        send pl1, {:broadcast, peer_pl1_list}
        send pl2, {:broadcast, peer_pl2_list}
    end
end
end # module -----------------------
