class ChangeDataClassToLecture < ActiveRecord::Migration[5.2]
  def change
    change_column :lectures, :class, :string
  end
end
