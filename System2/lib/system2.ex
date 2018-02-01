# Rishabh Jain(rj2315) and Vinamra Agrawal(va1215)
defmodule System2 do
def main() do
  IO.puts ["PL broadcast at ", DNS.my_ip_addr()]
  peer_list = for n <- 0..4, do: spawn(Peer, :start, [n, self(), 1000, 11000])

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
