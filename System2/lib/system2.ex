# Rishabh Jain(rj2315)
defmodule System2 do
def main() do
  IO.puts ["PL broadcast at ", DNS.my_ip_addr()]
  peer_list = for n <- 0..4, do: spawn(Peer, :start, [n, self()])

  receive do
      {:pl_app, pl, app} ->
  end

end
end # module -----------------------
