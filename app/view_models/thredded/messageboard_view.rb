# frozen_string_literal: true

module Thredded
  # A view model for Messageboard.
  class MessageboardView
    delegate :name,
             :description,
             :locked?,
             :topics_count,
             :posts_count,
             :last_topic,
             :last_user,
             to: :@messageboard

    # @param [Thredded::Messageboard>] messageboard
    # @param [Boolean] has_unread_topics
    def initialize(messageboard, has_unread_topics: false)
      @messageboard = messageboard
      @has_unread_topics = has_unread_topics
    end

    def has_unread_topics?
      @has_unread_topics
    end

    def path
      Thredded::UrlsHelper.messageboard_topics_path(@messageboard)
    end
  end
end
