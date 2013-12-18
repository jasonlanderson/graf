class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.references :company, index: true
      t.integer :git_id
      t.string :login
      t.string :name
      t.string :location
      t.string :email
      t.date :date_created
      t.date :date_updated

      t.timestamps
    end
  end
end
