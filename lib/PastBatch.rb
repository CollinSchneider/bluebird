class PastBatch < Struct.new(:batches)

  def perform
    batches.each do |batch|
      batch.status = 'cron?'
      batch.save
      batch.products.each do |product|
        product.status = 'cron?'
        product.save
        product.commits.each do |commit|
          commit.status = 'cron?'
          commit.save
        end
      end
    end
  end

end
