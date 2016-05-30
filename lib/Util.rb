class Util

  def expire_batch
    live_batches = Batch.where('status = ?', 'live?')
    live_batches.each do |batch|
      batch.status = 'whenever'
      batch.save
      puts "Making batch dead..."
    end
  end

end
