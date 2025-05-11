class Category < ApplicationRecord
  has_many :books, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 255 }, uniqueness: true
  validates :description, length: { maximum: 1000 }

  def self.with_books
    joins(:books).distinct
  end

  def books_count
    books.count
  end
end
