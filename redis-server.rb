# Runs a redis server with an empty db on 6389

require 'fileutils'

dir = ENV['TMPDIR'] + 'redis-examples'
port = 6389
FileUtils.rm_rf dir
FileUtils.mkdir dir

conf = <<-END
daemonize yes
pidfile #{dir}/pid
port #{port}
timeout 0
loglevel debug
logfile #{dir}/pid
databases 1

# after 900 sec (15 min) if at least 1 key changed
# after 300 sec (5 min) if at least 10 keys changed
# after 60 sec if at least 10000 keys changed
save 900 1
save 300 10
save 60 10000

rdbcompression yes

dir #{dir}
dbfilename dump.rdb

appendonly no
appendfsync always
glueoutputbuf yes
shareobjects no
shareobjectspoolsize 1024
END

conf_path = dir+'/conf'
File.open(conf_path,'w') { |f| f.write conf }

puts "working in #{dir}"
puts "starting redis\n***"
system "redis-server #{conf_path} > /dev/null"
abort "couldn't start redis" unless $?.success?

# if this is the first file you require than this will be the *last* exit
# hook that fires, which is probably what you want
at_exit do
  puts "***\nstopping redis"
  Process.kill('TERM', File.read(dir+'/pid').to_i)
end