class CategoriesController < ApplicationController
  before_action :set_category, only: [ :show, :edit, :update, :destroy ]

  def index
    @categories = policy_scope(Category)
  end

  def show
    authorize @category
  end

  def new
    @category = Category.new
    authorize @category
  end

  def edit
    authorize @category
  end

  def create
    @category = Category.new(category_params)
    authorize @category

    if @category.save
      redirect_to @category, notice: "Category was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @category
    if @category.update(category_params)
      redirect_to @category, notice: "Category was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @category
    if @category.books.exists?
      redirect_to @category, alert: "Cannot delete category with associated books."
    else
      @category.destroy
      redirect_to categories_url, notice: "Category was successfully deleted."
    end
  end

  def with_books
    authorize Category
    @categories = policy_scope(Category).includes(:books).having("COUNT(books.id) > 0").group("categories.id")
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :description)
  end
end
