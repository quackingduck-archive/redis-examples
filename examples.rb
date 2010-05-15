require 'redis-server'

require 'redis'
require 'exemplor'

eg.helpers do
  def db
    @db ||= Redis.new(:port => 6389).tap(&:flushdb)
  end
end

eg 'basic' do
  db[:foo] = "bar"
  Show(db[:foo])
end

eg 'incrementing & decrementing a counter' do
  Show(db.incr('counter'))
  Show(db.incr('counter'))
  Show(db.incr('counter'))

  Show(db.decr('counter'))
  Show(db.decr('counter'))
  Show(db.decr('counter'))
end

eg 'using a list for log messages' do
  db.rpush 'logs', 'some log message'
  db.rpush 'logs', 'another log message'
  db.rpush 'logs', 'yet another log message'
  db.rpush 'logs', 'also another log message'

  Show(db.lrange('logs', 0, -1))

  db.ltrim('logs', -2, -1)

  Show(db.lrange('logs', 0, -1))
end

eg 'using sets' do
  db.sadd 'foo-tags', 'one'
  db.sadd 'foo-tags', 'two'
  db.sadd 'foo-tags', 'three'

  db.sadd 'bar-tags', 'three'
  db.sadd 'bar-tags', 'four'
  db.sadd 'bar-tags', 'five'

  Show(db.smembers('foo-tags'))
  Show(db.smembers('bar-tags'))
  Show(db.sinter('foo-tags', 'bar-tags'))
end