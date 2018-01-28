# Rishabh Jain(rj2315)
defmodule System1 do
def main() do
  IO.puts ["System at ", DNS.my_ip_addr()]
  peer_list = for n <- 0..4, do: spawn(Peer, :start, [n])
  for peer <- peer_list do
    send peer, {:bind, peer_list}
  end

  for peer <- peer_list do
    send peer, {:broadcast, 1000, 3000}
  end

end
end # module -----------------------
