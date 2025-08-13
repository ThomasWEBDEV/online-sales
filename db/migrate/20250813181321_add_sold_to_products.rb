class AddSoldToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :sold, :boolean, default: false
  end
end
