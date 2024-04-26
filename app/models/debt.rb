class Debt < ApplicationRecord
  belongs_to :person
  after_save :clear_person_balance_cache
  after_destroy :clear_person_balance_cache
  validates :amount, presence: true
    
  private

  def clear_person_balance_cache
    person.clear_balance_cache
  end

end
