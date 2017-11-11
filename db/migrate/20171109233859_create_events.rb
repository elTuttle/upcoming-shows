class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.string :city
      t.string :state
      t.string :description
      t.string :date
      t.string :time
      t.integer :user_id
    end
  end
end
