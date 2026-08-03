class ReplaceCommentsWithReports < ActiveRecord::Migration[7.1]
  def up
    drop_table :comments

    create_table :reports do |t|
      t.references :sismo, null: false, foreign_key: true
      t.boolean :felt, null: false
      t.string :intensity, null: false
      t.timestamps
    end
  end

  def down
    drop_table :reports

    create_table :comments do |t|
      t.references :sismo, null: false, foreign_key: true
      t.text :body, null: false
      t.timestamps
    end
  end
end
