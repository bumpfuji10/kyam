class AddPostReservationDateToArticles < ActiveRecord::Migration[6.1]
  def change
    add_column :articles, :post_reservation_date, :datetime
  end
end
