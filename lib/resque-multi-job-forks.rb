require 'resque'
require 'resque/worker'

module Resque
  # the `before_child_exit` hook will run in the child process
  # right before the child process terminates
  #
  # Call with a block to set the hook.
  # Call with no arguments to return the hook.
  def self.before_child_exit(&block)
    block ? (@before_child_exit = block) : @before_child_exit
  end

  # Set the before_child_exit proc.
  def self.before_child_exit=(before_child_exit)
    @before_child_exit = before_child_exit
  end

  class Worker
    attr_accessor :jobs_per_fork
    attr_reader   :jobs_processed

    unless method_defined?(:done_working_without_multi_job_forks)
      def done_working_with_multi_job_forks
        done_working_without_multi_job_forks

        self.jobs_per_fork ||= [ ENV['JOBS_PER_FORK'].to_i, 1 ].max
        @jobs_processed ||= 0

        @jobs_processed += 1

        if @jobs_processed == 1 && jobs_per_fork > 1
          old_after_fork = Resque.after_fork
          Resque.after_fork = nil
          
          while @jobs_processed < jobs_per_fork && job = reserve
            process(job)
          end

          Resque.after_fork = old_after_fork

          run_hook :before_child_exit, self
          @jobs_processed = 0
        end
      end
      alias_method :done_working_without_multi_job_forks, :done_working
      alias_method :done_working, :done_working_with_multi_job_forks
    end
  end
end
