class AddActivationTimestampsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :activated_at, :datetime
    add_column :users, :deactivated_at, :datetime
  end
end
