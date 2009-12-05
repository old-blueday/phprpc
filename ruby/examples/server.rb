require "phprpc/server"

def add(a, b)
  a + b
end

def sub(a, b)
  a - b
end

def hello(s)
  "hello: " << s
end

def use_session(a, session)
  if session["a"] then
    session["a"] += a
  else
    session["a"] = a
  end
end

server = PHPRPC::Server.new
server.add(["add", "sub", "hello", "use_session"])
server.start