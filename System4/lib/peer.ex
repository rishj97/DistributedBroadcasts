# Rishabh Jain(rj2315)

defmodule Peer do

def start(num, system, max_messages, timeout, reliability) do
  IO.puts ["      Peer at ", DNS.my_ip_addr()]
  app = spawn(App, :start, [num, max_messages, timeout])
  beb = spawn(BEB, :start, [app])
  pl = spawn(LPL, :start, [self(), beb, reliability])
  send system, {:pl, self(), pl}
end
end # module -----------------------
