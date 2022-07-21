# frozen_string_literal: true
require_relative ("../pubsub_extension.rb")
require("google/cloud/pubsub")

namespace(:worker) do
  desc("Run the worker")
  task(run: :environment) do
    using PubsubExtension
    # See https://googleapis.dev/ruby/google-cloud-pubsub/latest/index.html

    puts("Worker starting...")

    pubsub = Google::Cloud::PubSub.new(project_id: 'code-challenge-356210')
    topic = pubsub.topic "jobs"
    subscription = pubsub.subscription_for topic
    subscriber = subscription.listen do |received_message|
      # process message
      puts "Message was received. Data: #{received_message.message.data}, published at #{received_message.message.published_at}"

      begin
        succeeded = false
        failed    = false
        ActiveJob::Base.execute JSON.parse(received_message.message.data)
        succeeded = true
      rescue Exception
        failed = true
        raise
      if succeeded || failed
        received_message.acknowledge!
        puts "Message(#{received_message.message_id}) was acknowledged."

        received_messages = subscriber.pull immediate: false
        puts "Received messages: #{received_messages}"
      else
        #terminated from outside
        received_message.delay! 0
      end
      end
    end

    # Handle exceptions from listener
    subscriber.on_error do |exception|
      puts "Exception: #{exception.class} #{exception.message}"
    end

    # Gracefully shut down the subscriber on program exit, blocking until
    # all received messages have been processed or 10 seconds have passed
    at_exit do
      subscriber.stop!(10)
    end

    # Start background threads that will call the block passed to listen.
    subscriber.start

    # Block, letting processing threads continue in the background
    sleep
  end
end
