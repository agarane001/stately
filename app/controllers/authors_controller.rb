class AuthorsController < ApplicationController
  before_action :set_author, only: [ :show, :edit, :update, :destroy ]

  def index
    @authors = policy_scope(Author).includes(:books).order(:name)
  end

  def show
    authorize @author
  end

  def new
    @author = Author.new
    authorize @author
  end

  def edit
    authorize @author
  end

  def create
    @author = Author.new(author_params)
    authorize @author

    if @author.save
      redirect_to @author, notice: "Author was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @author
    if @author.update(author_params)
      redirect_to @author, notice: "Author was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @author
    if @author.books.exists?
      redirect_to @author, alert: "Cannot delete author with associated books."
    else
      @author.destroy
      redirect_to authors_url, notice: "Author was successfully deleted."
    end
  end

  def with_books
    authorize Author
    @authors = policy_scope(Author).includes(:books).having("COUNT(books.id) > 0").group("authors.id")
  end

  private

  def set_author
    @author = Author.find(params[:id])
  end

  def author_params
    params.require(:author).permit(:name, :biography)
  end
end
