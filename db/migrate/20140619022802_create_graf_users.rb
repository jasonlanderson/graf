class CreateGrafUsers < ActiveRecord::Migration
  def change
    create_table :graf_users do |t|
      t.string :email
      t.string :password_digest

      t.timestamps
    end
  end
end
