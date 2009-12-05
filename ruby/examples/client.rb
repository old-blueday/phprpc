require "phprpc"

client = PHPRPC::Client.new("http://127.0.0.1:3000/")

client.encryptmode = 2
client.keylength = 256

starttime = Time.now

10.times {
  # synchronous invoke
  puts client.add(1, 2)
  puts client.hello('Ma Bingyao')
  puts client.sub(1, 2)
  puts client.use_session('Hello')
  puts client.use_session(' andot')

  # asynchronous invoke
  client.add(1, 2) { |result| puts result }
  client.hello('Ma Bingyao') { |result| puts result }
  client.sub(1, 2) { |result| puts result }
  client.use_session('Hello') { |result| puts result }
  client.use_session(' andot') { |result| puts result }
}
Thread.list.each { |t| t.join if t != Thread.main }
endtime = Time.now
puts endtime - starttime
