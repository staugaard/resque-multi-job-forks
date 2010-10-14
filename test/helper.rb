dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift dir + '/../lib'

$TESTING = true

require 'rubygems'
require 'test/unit'
require 'resque-multi-job-forks'

# setup redis & resque.
redis = Redis.new(:db => 1)
Resque.redis = redis

# adds simple STDOUT logging to test workers.
# set `VERBOSE=true` when running the tests to view resques log output.
module Resque
  class Worker
    def log(msg)
      puts "*** #{msg}" unless ENV['VERBOSE'].nil?
    end
    alias_method :log!, :log
  end
end

# stores a record of the job processing sequence.
# you may wish to reset this in the test `setup` method.
$SEQUENCE = []

# test job, tracks sequence.
class SequenceJob
  @queue = :jobs
  def self.perform(i)
    $SEQUENCE << "work_#{i}".to_sym
    sleep(2)
  end
end

class QuickSequenceJob
  @queue = :jobs
  def self.perform(i)
    $SEQUENCE << "work_#{i}".to_sym
  end
end


# test hooks, tracks sequence.
Resque.after_fork do
  $SEQUENCE << :after_fork
end

Resque.before_fork do
  $SEQUENCE << :before_fork
end

Resque.before_child_exit do |worker|
  $SEQUENCE << "before_child_exit_#{worker.jobs_processed}".to_sym
end