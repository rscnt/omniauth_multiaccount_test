class CreateCredentials < ActiveRecord::Migration
  def change
    create_table :credentials do |t|

      t.timestamps
      t.string      :uid
      t.string      :provider
      t.string      :token
      t.boolean     :expire
      t.belongs_to  :user
    end
  end
end
