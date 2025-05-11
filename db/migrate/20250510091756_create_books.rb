class CreateBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :books do |t|
      t.string :title, null: false
      t.string :isbn, null: false
      t.integer :status, default: 0, null: false
      t.references :author, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.date :published_date
      t.text :description

      t.timestamps
    end

    add_index :books, :isbn, unique: true
    add_index :books, :title
    add_index :books, :status
  end
end
