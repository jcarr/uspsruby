class TrackingController < ApplicationController
  include Uspstracking
  def index
    ids = params[:q]

    @tracking = Uspstracking::Tracking.new(ids)
    @tracking.getTracking
    
    @title = "USPS Tracking - " + @tracking.trackingNumber
  end
end
