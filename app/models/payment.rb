class Payment < ApplicationRecord
  belongs_to :person
  after_save :clear_person_balance_cache
  after_destroy :clear_person_balance_cache
   after_commit :clear_cache

  private

  def clear_person_balance_cache
    person.clear_balance_cache
  end

  def clear_cache
    Rails.cache.delete('total_payments')
    Rails.cache.delete('last_payments')
    Rails.cache.delete('people_with_positive_balance')
    Rails.cache.delete("#{self.person.user.id}/my_people")
  end
end