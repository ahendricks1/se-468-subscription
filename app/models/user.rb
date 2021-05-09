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
    subscription && sub.active?
  end

  def subscription
    subs.last
  end

  def subscribe(plan, options={})
    stripe_customer if !stripe_id?

    args = {
      customer: stripe_id,
      items: [{ plan: plan}],
      expand: []
    }
  end

  def update_card(payment_method_id)
    stripe_customer if !stripe_id?

    payment_method = Stripe::PaymentMethod.attach(payment_method_id, { customer: stripe_id })
    Stripe::Customer.update(stripe_id, invoice_settings: { default_payment_method: payment_method.id })
    update(
      card_brand: payment_method.card,
      card_last4: payment_method.last4,
      card_exp_month: payment_method.exp_month,
      card_exp_year: payment_method.exp_year,
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
