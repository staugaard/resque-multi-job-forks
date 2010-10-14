require File.dirname(__FILE__) + '/helper'

class TestResqueMultiJobForks < Test::Unit::TestCase
  def setup
    $SEQUENCE = []
    Resque.redis.flushdb
    @worker = Resque::Worker.new(:jobs)
  end

  def test_timeout_limit_sequence_of_events
    # only allow enough time for 3 jobs to process.
    @worker.seconds_per_fork = 3
  
    Resque.enqueue(SequenceJob, 1)
    Resque.enqueue(SequenceJob, 2)
    Resque.enqueue(SequenceJob, 3)
    Resque.enqueue(SequenceJob, 4)
  
    # make sure we don't take longer then 15 seconds.
    begin
      Timeout::timeout(15) { @worker.work(1) }
    rescue Timeout::Error
    end
  
    # test the sequence is correct.
    assert_equal([:before_fork, :after_fork, :work_1, :work_2, :work_3,
                  :before_child_exit_3, :before_fork, :after_fork, :work_4,
                  :before_child_exit_1], $SEQUENCE, 'correct sequence')
  end

  # test we can also limit fork job process by a job limit.
  def test_job_limit_sequence_of_events
    # only allow enough time for 3 jobs to process.
    ENV['JOBS_PER_FORK'] = '20'

    # queue 40 jobs.
    (1..40).each { |i| Resque.enqueue(QuickSequenceJob, i) }

    begin
      Timeout::timeout(3) { @worker.work(1) }
    rescue Timeout::Error
    end

    assert_equal :before_fork, $SEQUENCE[0], 'first before_fork call.'
    assert_equal :after_fork, $SEQUENCE[1], 'first after_fork call.'
    assert_equal :work_20, $SEQUENCE[21], '20th chunk of work.'
    assert_equal :before_child_exit_20, $SEQUENCE[22], 'first before_child_exit call.'
    assert_equal :before_fork, $SEQUENCE[23], 'final before_fork call.'
    assert_equal :after_fork, $SEQUENCE[24], 'final after_fork call.'
    assert_equal :work_40, $SEQUENCE[44], '40th chunk of work.'
    assert_equal :before_child_exit_20, $SEQUENCE[45], 'final before_child_exit call.'
  end
  
  def teardown
    # make sure we don't clobber any other tests.
    ENV['JOBS_PER_FORK'] = nil
  end
end
