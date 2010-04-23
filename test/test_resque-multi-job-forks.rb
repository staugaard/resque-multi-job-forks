require 'helper'

class SomeJob
  def self.perform(i)
    $SEQUENCE << "work_#{i}".to_sym
    puts 'working...'
    sleep(25)
  end
end

Resque.after_fork do
  $SEQUENCE << :after_fork
end

Resque.before_child_exit do |worker|
  $SEQUENCE << "before_child_exit_#{worker.jobs_processed}".to_sym
end

class TestResqueMultiJobForks < Test::Unit::TestCase
  def setup
    $SEQUENCE = []
  end
  
  def test_sequence_of_events
    Resque.redis.flush_all
    
    ENV['MINUTES_PER_FORK'] = '1'

    worker = Resque::Worker.new(:jobs)

    Resque::Job.create(:jobs, SomeJob, 1)
    Resque::Job.create(:jobs, SomeJob, 2)
    Resque::Job.create(:jobs, SomeJob, 3)
    Resque::Job.create(:jobs, SomeJob, 4)

    worker.work(0)

    assert_equal([:after_fork, :work_1, :work_2, :work_3, :before_child_exit_3, :after_fork, :work_4, :before_child_exit_1], $SEQUENCE)
  end
end
