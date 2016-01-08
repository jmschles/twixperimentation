class AddOutcomeToPhoneCall < ActiveRecord::Migration
  def change
    add_column :phone_calls, :outcome, :string
  end
end
