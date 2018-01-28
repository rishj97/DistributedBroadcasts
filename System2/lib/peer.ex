# Rishabh Jain(rj2315)

defmodule Peer do

def start(num, system) do
  IO.puts ["      Peer at ", DNS.my_ip_addr()]
  app = spawn(App, :start, [])
  pl = spawn(PL, :start, [app])
  receive do
      {:msg,contents} -> 
  end
  send system, {:pl, pl, app, self()}
end
end # module -----------------------
