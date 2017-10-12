
#
# Module Warren provides connection pooling for RabbitMQ Connections
#
module Warren
  def self.construct(type:, url: nil, frame_max: 0, heartbeat: 30, exchange: nil, pool_size: 14)
    case type
    when 'test' then Warren::Test.new
    when 'log' then Warren::Log.new
    when 'broadcast' then Warren::Broadcast.new(url: url, frame_max: frame_max, heartbeat: heartbeat, exchange: exchange, pool_size: pool_size)
    else raise StandardError, "Unknown type warren: #{type}"
    end
  end

  def self.setup(opts)
    Rails.logger.warn 'Recreating Warren handler when one already exists' if handler.present?
    @handler = construct(opts.symbolize_keys)
  end

  def self.handler
    @handler
  end
end