class SubsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_plan, only: [:new, :create, :update]

  def show
    @sub = current_user.subscription
  end

  def new
  end

  def create
    current_user.update_card(params[:payment_method_id]) if params[:payment_method_id].present?
    current_user.subscribe(@plan)
    redirect_to root_path, notice: "Thanks for subscribing!"
  rescue PaymentIncomplete => e
    redirect_to payment_path(e.payment_intent.id)
  end

  def edit
    @sub = current_user.subscription
    @plans = Plan.all
  end

  def update
    @sub = current_user.subscription
    @sub.swap(@plan.stripe_price_id)
    redirect_to sub_path, notice: "You have successfully changed plans."
  end

  private
  
    def set_plan
      @plan = Plan.find_by(id: params[:plan_id])
      redirect_to pricing_path if @plan.nil?
    end

end