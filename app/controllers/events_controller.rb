
class EventsController < ApplicationController
  # WARNING! This filter bypasses security mechanisms in rails 4 and mimics rails 2 behviour.
  # It should be removed wherever possible and the correct Strong  Parameter options applied in its place.
  before_action :evil_parameter_hack!

  def new
    @event = Event.new
  end

  def create
    # Compatible with NPG

    params[:event].delete(:key)

    @event = Event.create(params[:event])

    unless @event.eventful.nil?
      @event.eventful.save
    end

    respond_to do |format|
      # I know this looks crazy, but it appears to be explicitly tested for
      # Unfortunately there is no comment as to why.
      # However a similar issue elsewhere in the codebase indicates that
      # its probably because NPG are missing accept headers in some cases
      # resulting in defaulting to HTML
      format.html { render xml: @event.to_xml }
      format.xml  { render xml: @event.to_xml }
      format.json { render json: @event.to_json }
    end
  end
end
