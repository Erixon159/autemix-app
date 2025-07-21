class TestJob < ApplicationJob
  queue_as :default

  def perform(message = "Hello from Sidekiq!")
    Rails.logger.info "TestJob executed: #{message}"
    puts "TestJob executed: #{message}"
  end
end
