# app/services/dashboard_service.rb
class DashboardService
  attr_reader :top_person, :bottom_person

  def initialize(user)
    @user = user
  end

  def active_people_pie_chart
    Rails.cache.fetch('active_people_pie_chart', expires_in: 1.hours) do
      {
        active: Person.where(active: true).count,
        inactive: Person.where(active: false).count
      }
    end
  end

  def total_debts
    Rails.cache.fetch('total_debts', expires_in: 1.hours) do
      active_people_ids = Person.where(active: true).select(:id)
      Debt.where(person_id: active_people_ids).sum(:amount)
    end
  end

  def total_payments
    Rails.cache.fetch('total_payments', expires_in: 1.hours) do
      active_people_ids = Person.where(active: true).select(:id)
      Payment.where(person_id: active_people_ids).sum(:amount)
    end
  end

  def balance
    total_payments - total_debts
  end

  def last_debts
    Rails.cache.fetch('last_debts', expires_in: 1.hours) do
      Debt.order(created_at: :desc).limit(10).map do |debt|
        [debt.id, debt.amount]
      end
    end
  end

  def last_payments
    Rails.cache.fetch('last_payments', expires_in: 1.hours) do
      Payment.order(created_at: :desc).limit(10).map do |payment|
        [payment.id, payment.amount]
      end
    end
  end

  def my_people
    Rails.cache.fetch("#{@user.id}/my_people", expires_in: 1.hours) do
      Person.where(user: @user).order(:created_at).limit(10)
    end
  end

  def people_with_positive_balance
    people = Rails.cache.fetch('people_with_positive_balance', expires_in: 1.hours) do
      Person.all.select do |person|
        person.balance > 0
      end.sort_by do |person|
        person.balance
      end
    end

    @top_person = people.last
    @bottom_person = people.first
    people
  end
end