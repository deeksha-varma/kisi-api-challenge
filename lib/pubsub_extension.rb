module PubsubExtension
  refine Google::Cloud::Pubsub::Project do
    def subscription_for(topic)
      subscription(topic) || Pubsub.new.topic_for(topic).subscribe(topic)
    end
  end
end
