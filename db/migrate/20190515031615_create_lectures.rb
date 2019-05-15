class CreateLectures < ActiveRecord::Migration[5.2]
  def change
    create_table :lectures do |t|
      t.datetime :canceled_at
      t.datetime :supplemented_at
      t.string :subject, null: false
      t.integer :class
      t.integer :department
      t.string :room
      t.string :teacher
      t.text :remarks

      t.timestamps
    end
  end
end
