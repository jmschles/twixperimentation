class CreatePhoneCalls < ActiveRecord::Migration
  def change
    create_table :phone_calls do |t|
      t.datetime :scheduled_time
      t.string :pin
      t.string :status
      t.string :recording_url

      t.timestamps null: false
    end
  end
end
