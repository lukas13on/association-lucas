# app/controllers/dashboard_controller.rb
class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    dashboard = DashboardService.new(current_user)
    @active_people_pie_chart = dashboard.active_people_pie_chart
    @total_debts = dashboard.total_debts
    @total_payments = dashboard.total_payments
    @balance = dashboard.balance
    @last_debts = dashboard.last_debts
    @last_payments = dashboard.last_payments
    @my_people = dashboard.my_people
    @people_with_positive_balance = dashboard.people_with_positive_balance
    @top_person = dashboard.top_person
    @bottom_person = dashboard.bottom_person
  end
end