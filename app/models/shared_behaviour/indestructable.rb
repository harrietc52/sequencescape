
module SharedBehaviour::Indestructable
  def self.included(base)
    base.class_eval do
      before_destroy :prevent_destruction
    end
  end

  private

  def prevent_destruction
    errors.add(:base, 'can not be destroyed and should be deprecated instead!')
    throw(:abort)
  end
end
