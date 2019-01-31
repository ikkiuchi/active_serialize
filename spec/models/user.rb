class User < ActiveRecord::Base
  active_serialize

  has_many :books

  def love
    'Ruby'
  end

  def method_a; end
end
