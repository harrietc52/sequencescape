# frozen_string_literal: true

# Handles failure of requests or their removal from the batch via
# BatchesController#fail_items
class Batch::RequestFailAndRemover
  include ActiveModel::Model

  attr_accessor :reason, :comment
  attr_writer :requested_fail, :requested_remove

  validates :reason, presence: { message: 'Please specify a failure reason for this batch' }
  # The used can either remove or fail a request, not both.
  validates :clashing_requests, absence: { message: lambda { |_, data|
    "Fail and remove were both selected for the following - #{data[:value].to_sentence} this is not supported."
  } }

  def save
    return false unless valid?

    fail_requests if requested_fail.present?
    remove_requests if requested_remove.present?
    true
  end

  def notice
    @notice ||= []
  end

  def failure=(failure_hash)
    @reason = failure_hash[:reason]
    @comment = failure_hash[:comment]
    @fail_but_charge = failure_hash[:fail_but_charge]
  end

  # ID is the batch id passed in from the controller
  def id=(batch_id)
    @batch = Batch.find(batch_id)
  end

  private

  def fail_requests
    @batch.fail_batch_items(@requested_fail, reason, comment, fail_but_charge)
    notice << "#{requested_fail.to_sentence} set to failed.#{charge_message}"
  end

  def remove_requests
    @batch.remove_request_ids(requested_remove, reason, comment)
    notice << "#{requested_remove.to_sentence} removed."
  end

  def charge_message
    fail_but_charge ? ' The customer will still be charged.' : ''
  end

  def requested_fail
    (@requested_fail || {}).keys
  end

  def requested_remove
    (@requested_remove || {}).keys
  end

  def clashing_requests
    requested_remove & requested_fail
  end

  def requests_selected?
    return if requested_remove.present? || requested_fail.present?

    errors.add(:base, 'Please select an item to fail or remove')
  end

  def fail_but_charge
    @fail_but_charge == '1'
  end
end
