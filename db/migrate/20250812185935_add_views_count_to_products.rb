class AddViewsCountToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :views_count, :integer, default: 0
  end
end
