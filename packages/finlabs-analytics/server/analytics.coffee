Analytics = Npm.require 'analytics-node'
key = RocketChat.settings.get 'Segment_Key'
FinLabs.Analytics = new Analytics key
