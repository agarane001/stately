class BooksController < ApplicationController
  before_action :set_book, only: [ :show, :edit, :update, :destroy ]

  def index
    @books = policy_scope(Book)
  end

  def show
    authorize @book
  end

  def new
    @book = Book.new
    authorize @book
  end

  def edit
    authorize @book
  end

  def create
    @book = Book.new(book_params)
    authorize @book

    if @book.save
      redirect_to @book, notice: "Book was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @book
    if @book.update(book_params)
      redirect_to @book, notice: "Book was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @book
    @book.destroy
    redirect_to books_url, notice: "Book was successfully deleted."
  end

  def available
    authorize Book
    @books = policy_scope(Book).available
  end

  def borrowed
    authorize Book
    @books = policy_scope(Book).borrowed
  end

  def reserved
    authorize Book
    @books = policy_scope(Book).reserved
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def book_params
    params.require(:book).permit(:title, :isbn, :published_date, :author_id, :category_id, :description, :status)
  end
end
