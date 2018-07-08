# frozen_string_literal: true

module Thredded
  # A view model for a page of MessageboardGroupViews.
  class MessageboardGroupView
    delegate :name, to: :@group, allow_nil: true
    attr_reader :group, :messageboards

    # @param [ActiveRecord::Relation<Thredded::Messageboard>] messageboards_scope
    # @param [Thredded.user_class] user The user viewing the messageboards.
    # @param [Boolean] with_unread_topics_counts
    # @return [Array<MessageboardGroupView>]
    def self.grouped(messageboards_scope, user: nil, with_unread_topics_counts: user && !user.thredded_anonymous?)
      scope = messageboards_scope.preload(last_topic: [:last_user])
        .eager_load(:group)
        .order(Arel.sql('COALESCE(thredded_messageboard_groups.position, 0) ASC, thredded_messageboard_groups.id ASC'))
        .ordered
        .group_by(&:group)
      if with_unread_topics_counts
        scope = scope.with_unread_topics_counts(topics_scope: Pundit.policy_scope!(user, Thredded::Topic))
      end
      scope.map do |(group, messageboards)|
        MessageboardGroupView.new group, messageboards.map do |messageboard|
          MessageboardView.new(messageboard)
        end
      end
    end

    # @param [Thredded::MessageboardGroup] group
    # @param [Array<Thredded::MessageboardView>] messageboards
    def initialize(group, messageboards)
      @group = group
      @messageboards = messageboards
    end
  end
end
