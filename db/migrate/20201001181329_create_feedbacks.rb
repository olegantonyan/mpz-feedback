class CreateFeedbacks < ActiveRecord::Migration[6.0]
  def change
    create_table :feedbacks do |t|
      t.string :author, null: false, default: '', limit: 256
      t.string :text, null: false, limit: 32768
      t.string :sysinfo, null: false, default: '', limit: 4096

      t.timestamps
    end
    add_index :feedbacks, :author
  end
end
