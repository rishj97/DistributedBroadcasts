# Rishabh Jain(rj2315) and Vinamra Agrawal(va1215)

defmodule Peer do

def start(num, system, max_messages, timeout) do
  IO.puts ["      Peer at ", DNS.my_ip_addr()]
  app = spawn(App, :start, [num, max_messages, timeout])
  pl = spawn(PL, :start, [self(), app])
  send system, {:pl, self(), pl}
end
end # module -----------------------
