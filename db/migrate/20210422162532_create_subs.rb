class CreateSubs < ActiveRecord::Migration[6.1]
  def change
    create_table :subs do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.string :stripe_id
      t.string :stripe_plan
      t.string :status
      t.datetime :trial_ends_at
      t.datetime :ends_at
      t.integer :quantity

      t.timestamps
    end
  end
end
