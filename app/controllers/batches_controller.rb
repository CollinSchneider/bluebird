class BatchesController < ApplicationController

  def time_difference(start_time, end_time)
      seconds_diff = (start_time - end_time).to_i.abs
      hours = seconds_digg/3600
      seconds_diff -= hours*3600
      minutes = seconds_diff/60
      seconds_diff -= minutes*60
      seconds = seconds_diff
      "#{hours.to_s.rjust(2, '0')}:#{minutes.to_s.rjust(2, '0')}:#{seconds.to_s.rjust(2, '0')}"
    end

  def index
  end

  def create
    batch = Batch.create(batch_params)
    redirect_to edit_batch_path(batch.id)
  end

  def show
    @batch = Batch.find(params[:id])
    if @batch.end_time < Time.now
      @batch.status = 'past'
      @batch.products.each do |product|
        product.status == 'past'
        product.save
      end
      @batch.save
    end
  end

  def edit
    @batch = Batch.find(params[:id])
    authenticate_batch_wholesaler(@batch)
  end

  def update
    batch = Batch.find(params[:id])
    batch.update(batch_params)
    redirect_to request.referrer
  end

  def complete_batch
    batch = Batch.find(params[:id])
    batch.status = 'live'
    batch.products.each do |product|
      product.status = 'live'
      product.save
    end
    batch.start_time = Time.now
    # batch.end_time = Time.now + 1.minute
    if batch.duration == '1 Day'
      batch.end_time = Time.now + 1.day
    elsif batch.duration == '7 Days'
      batch.end_time = Time.now + 7.days
    elsif batch.duration == '30 Days'
      batch.end_time = Time.now + 30.days
    end
    batch.save
    redirect_to batch_path(batch.id)
  end

  def cancel_batch
    batch = Batch.find(params[:id])
    batch.completed_status = 'not_met'
    batch.save
    # redirect_to request.referrer
  end

  def grant_discount
    batch = Batch.find(params[:id])
    batch.completed_status = 'granted_discount'
    batch.save
    # redirect_to request.referrer
  end

  def mark_batch_as_past
    batch = Batch.find(params[:id])
    batch.status = 'past'
    batch.save
  end

  private
  def batch_params
    params.require(:batch).permit(:duration, :start_time, :end_time, :user_id, :status, :completed_status)
  end

end
