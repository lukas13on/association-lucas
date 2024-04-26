class Person < ApplicationRecord
  belongs_to :user, optional: true

  has_many :debts, dependent: :destroy

  has_many :payments, dependent: :destroy

  validates :name, :national_id, presence: true
  validates :national_id, uniqueness: true
  validate :cpf_or_cnpj

  after_save :clear_cache
  after_destroy :clear_cache

    after_commit :clear_my_people_cache


  # TODO: refactor me
  #
  # - improve performance using SQL
  # - sum payments
  # - rename to "balance"
  # def total_debts
  #   total_debts = 0

  #   debts.each do |debt|
  #     total_debts -= debt.amount
  #   end
  #   total_debts
  # end

  # def total_payments
  #   total_payments = 0

  #   payments.each do |payment|
  #     total_payments += payment.amount
  #   end
  #     total_payments
  # end

  # def balance
  #  totalAccount = total_debts + total_payments
  # end
 
def balance
  Rails.cache.fetch("#{self.id}/balance", expires_in: 12.hours) do
    payments.sum(:amount) - debts.sum(:amount)
  end
end

def clear_balance_cache
  Rails.cache.delete("#{self.id}/balance")
end

  private

  def clear_cache
    Rails.cache.delete('active_people_pie_chart')
    Rails.cache.delete('people_with_positive_balance')
    clear_balance_cache
  end

  def clear_my_people_cache
    Rails.cache.delete("#{self.user.id}/my_people")
  end

  def cpf_or_cnpj
    if !CPF.valid?(national_id) && !CNPJ.valid?(national_id)
      errors.add :national_id, :invalid
    end
  end
end
