module Commentable
  def self.included(base)
    base.class_eval do
      has_many :comments, as: :commentable
      scope :with_comments, -> { joins(:comments).where("commentable_type = '#{base.name}'") } do
        def group(ids)
          conditions = {}
          if ids
            conditions[:id] = ids
          end

          group(:commentable_id).where(conditions).count
        end
      end
      def self.get_comment_count(ids = nil)
        h = Hash.new(0) # return 0 if key is not in the hash
        with_comments.group(ids).each do |commentable_id, comment_count|
          h[commentable_id.to_i] = comment_count
        end
        h
      end
    end
  end
end
