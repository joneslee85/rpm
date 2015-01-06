require 'new_relic/agent/sampler'

module NewRelic
  module Memstats
    class ClassCountSampler < Agent::Sampler
      named :class_count

      def self.supported_on_this_platform?
        ObjectSpace.respond_to?(:each_object)
      end

      def poll
        class_counts = Hash.new(0)
        ObjectSpace.each_object do |obj|
          class_name = obj.class.to_s rescue '<unknown>'
          if class_name.start_with?('NewRelic')
            class_counts[class_name] += 1
          end
        end

        event = class_counts.merge(:pid => Process.pid)
        Agent.record_custom_event(:NewRelicClassCounts, event)

        event = ObjectSpace.count_objects.merge(:pid => Process.pid)
        Agent.record_custom_event(:RubyObjectTypeCounts, event)
      end
    end
  end
end
