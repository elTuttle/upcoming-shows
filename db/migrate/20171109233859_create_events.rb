class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.string :city
      t.string :state
      t.string :description
      t.datetime :time_of_event
      t.integer :user_id
    end
  end
end
