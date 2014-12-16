class CreateUsers < ActiveRecord::Migration
  def change
  	create_table :users do |u|
	    u.text :username, null: false
	    u.text :email, null: false
	    u.string :password_digest, null: false
	  	u.text :zipcode, null: false
	    u.text :name
    end
  end
end
