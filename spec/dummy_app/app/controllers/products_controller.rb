class ProductsController < ApplicationController

  def index
    @products = Product.find_for_table(params,
        :precondition => "products.id < 100",
        :default_order => "products.id asc",
        :default_pagesize => 10,
        :store_data => {:ping => 'pong'}) do |batch_action|
      batch_action.activate do |ids| activate_batch_action(ids, true) end
      batch_action.deactivate do |ids| activate_batch_action(ids, false) end
      batch_action.foo do |ids| render :text => "Action Foo: #{ids.to_s}"; return end
      batch_action.select do |ids| session[:ids] = ids; redirect_to :select_variants; return end
    end
  end

  def index_simple
    @products = Product.find_for_table(params)
  end

  def index_filters
    @products = Product.find_for_table(params)
  end

  def index_compound
    @products = Product.find_for_table(params)
  end

  def index_stateful
    @products = Product.find_for_table(params, :stateful => session)
  end

  def index_select
    @products = Product.find_for_table(params) do |batch_actions|
      batch_actions.delete do |ids|
        ids.each do |id|
          Product.find(id).destroy
        end
        redirect_to index_select_products_path()
        return
      end
    end
  end

  def index_sort
    @products = Product.find_for_table(params, :default_order => 'price desc')
    render :index_select
  end

  def show
    @product = Product.find(params[:id])
  end

  def new
    @product = Product.new
    @vendors = Vendor.all
  end

  def edit
    @vendors = Vendor.all
    @product = Product.find(params[:id])
  end

  def create
    @product = Product.new(params[:product])

    if @product.save
      redirect_to(@product, :notice => 'Product was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @product = Product.find(params[:id])

    if @product.update_attributes(params[:product])
      redirect_to(@product, :notice => 'Product was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @product = Product.find(params[:id])
    @product.destroy

    redirect_to(products_url)
  end

private

  def activate_batch_action(ids, active)
    Product.where('id in (?)', ids).map do |p|
      p.update_attributes(:active => active)
    end
  end

end
