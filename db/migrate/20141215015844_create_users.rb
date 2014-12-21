class CreateUsers < ActiveRecord::Migration
  def change
  	create_table :users do |u|
	    u.text :username, null: false
	    u.text :email, null: false
	    u.string :password_digest, null: false
	  	u.text :image_url
	  	u.text :zipcode, null: false
	    u.text :name
	    u.boolean :dummy, default: 'f'
    end
  end
end
