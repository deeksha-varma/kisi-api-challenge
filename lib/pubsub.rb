# frozen_string_literal: true

require("google/cloud/pubsub")

class Pubsub
  # Find or create a topic.
  #
  # @param topic [String] The name of the topic to find or create
  # @return [Google::Cloud::PubSub::Topic]
  def topic_for(queue_name)
    name = "activejob-queue-#{queue_name}"

    client.topic(name) || client.create_topic(name)
  end

  #publish messages to GCP topic
  def self.publish(options)
    name = options["queue_name"]
    begin
      Pubsub.new.topic_for(name).publish options
      Rails.logger.info "Successfully published message"
    rescue => e
      Rails.logger.info "Error: Failed to publish the message. Received error while publishing: #{e.message}"
    end
  end


  private

  # Create a new client.
  #
  # @return [Google::Cloud::PubSub]
  def client
    @client ||= Google::Cloud::PubSub.new(project_id: 'code-challenge-356210')
  end
end
