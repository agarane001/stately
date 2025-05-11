class CreateMembers < ActiveRecord::Migration[7.1]
  def change
    create_table :members do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :member_number, null: false
      t.integer :status, default: 0, null: false
      t.string :phone
      t.text :address

      t.timestamps
    end

    add_index :members, :email, unique: true
    add_index :members, :member_number, unique: true
    add_index :members, :status
  end
end
