class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :masqueradable, :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :omniauthable

  has_one_attached :avatar
  has_person_name

  has_many :notifications, as: :recipient
  has_many :services
  has_many :subs
  has_many :charges

  def subscribed?
    subscription && subscription.active?
  end

  def subscription
    subs.last
  end

  def subscribe(plan, options={})
    stripe_customer if !stripe_id?

    args = {
      customer: stripe_id,
      items: [{price: plan.stripe_price_id}],
      expand: ['latest_invoice.payment_intent'],
      off_session: true,
    }.merge(options)

    args[:trial_from_plan] = true if !args[:trial_period_days]

    stripe_subscription = Stripe::Subscription.create(args)

    sub = subs.create(
      stripe_id: stripe_subscription.id,
      stripe_plan: plan.stripe_id,
      status: stripe_subscription.status,
      trial_ends_at: (stripe_subscription.trial_end ? Time.at(stripe_subscription.trial_end) : nil),
      ends_at: nil,
    )

    if stripe_subscription.status == "incomplete" && ["requires_action", "requires_payment_method"].include?(stripe_subscription.latest_invoice.payment_intent.status)
      raise PaymentIncomplete.new(stripe_subscription.latest_invoice.payment_intent), "Subscription requires authenticatoin"
    end
    
    sub
  end

  def create_setup_intent
    stripe_customer if !stripe_id?
    Stripe::SetupIntent.create(customer: stripe_id)
  end

  def update_card(payment_method_id)
    stripe_customer if !stripe_id?

    payment_method = Stripe::PaymentMethod.attach(payment_method_id, { customer: stripe_id })
    Stripe::Customer.update(stripe_id, invoice_settings: { default_payment_method: payment_method.id })
    update(
      card_brand: payment_method.card.brand.titleize,
      card_last4: payment_method.card.last4,
      card_exp_month: payment_method.card.exp_month,
      card_exp_year: payment_method.card.exp_year,
    )
  end


  def stripe_customer
    if stripe_id
      Stripe::Customer.retrieve(stripe_id)
    else
      customer = Stripe::Customer.create(
        email: email,
        name: name,
      )
      update(stripe_id: customer.id)
      customer
    end
  end
end
