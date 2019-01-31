class Book < ActiveRecord::Base
  active_serialize rmv: [:id, :user_id]

  belongs_to :user
end
