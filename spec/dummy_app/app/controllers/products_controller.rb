class ProductsController < ApplicationController

  def index
    @products = Product.find_for_table(params,
        precondition: "products.id < 100",
        default_order: "products.id asc",
        default_pagesize: 10,
        store_data: {:ping => 'pong'}) do |batch_action|
      batch_action.activate do |ids| activate_batch_action(ids, true) end
      batch_action.deactivate do |ids| activate_batch_action(ids, false) end
      batch_action.foo do |ids| render :text => "Action Foo: #{ids.to_s}"; return end
      batch_action.select do |ids| session[:ids] = ids; redirect_to :select_variants; return end
    end
  end

  def index_simple
    @products = Product.find_for_table(params)
  end

  def select_variants
    ids = session[:ids]
    @variants = Variant.find_for_table(params,
        precondition: "product_id in (#{ids.join(",")})",
        default_order: "id asc",
        default_pagesize: 10,
        store_data: {product_ids: ids.join(",")}) do |batch_action|
      batch_action.select do |ids| validate_foo(ids, true) end
    end
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
