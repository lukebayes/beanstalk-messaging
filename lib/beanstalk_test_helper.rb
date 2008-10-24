module Beanstalk
  module TestHelper
    def with_beanstalk_queue_running(queue_name, &block)
      @beanstalk_config ||= YAML.load(File.read(File.join(Rails.root, 'config', 'beanstalk.yml')))
      queue_port = @beanstalk_config[queue_name.to_sym][:port]
      queue_daemon_manager = Beanstalk::DaemonManager.new(File.join(Rails.root, 'tmp', 'pids'))
      queue_daemon_manager.register_daemon(queue_name.to_s, '0.0.0.0', queue_port)
      queue_daemon_manager.run(queue_name)
      raise "Could not start queue '#{queue_name}'." unless queue_daemon_manager.running?(queue_name)
      yield QUEUE_MANAGER.queue(queue_name.to_sym) if block_given?
    ensure
      if queue_daemon_manager && queue_daemon_manager.running?(queue_name)
        queue_daemon_manager.kill(queue_name.to_s) 
      end
    end
  end
end
