class Util

  def slug(string)
    slug = string.downcase
    slug.gsub!(',' '')
    slug.gsub!("'", "")
    slug.gsub!('.', '')
    slug.gsub!(' ', '-')
    return slug
  end

  def self.test
    return "Is this working?"
  end

  def self.expire_batch
    bad_batches = Batch.where('status = ? AND end_time <= ?', 'live', Time.now)
    bad_batches.each do |batch|
      batch.status = 'past'
      batch.save
      total_sales = 0
      batch.products.each do |product|
        product.status = 'past'
        product.save
        product.commits.each do |commit|
          total_sales += commit.amount.to_f*product.discount.to_f
        end
      end
      if batch.milestones[0].goal.to_i <= total_sales
        batch.completed_status = 'goal_met'
        batch.save
      else
        batch.completed_status = 'needs_attention'
        batch.save
      end
    end
  end

  def self.expire
    bad_batches = Batch.where('status = ? AND end_time <= ?', 'live', Time.now)
    bad_batches.each do |batch|
      total_sales = 0
      batch.products.each do |product|
        # product.status = 'past'
        # product.save
        product.commits.each do |commit|
          total_sales += commit.amount.to_f*product.discount.to_f
        end
      end
      if batch.milestones[0].goal.to_i <= total_sales
        batch.status = 'goal_reached'
        batch.save
      else
        batch.status = 'needs_attention'
        batch.save
      end
    end
  end


end
