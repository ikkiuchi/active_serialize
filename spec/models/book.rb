class Book < ActiveRecord::Base
  active_serialize_default rmv: [:id]
  active_serialize rmv: [:user_id]

  belongs_to :user
end
