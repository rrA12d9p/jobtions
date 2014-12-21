class CreatePersonalities < ActiveRecord::Migration
  def change
  	create_table :personalities do |p|
	  	p.text :extraversion, null: false
			p.text :agreeableness, null: false
			p.text :conscientiousness, null: false
			p.text :emotional_stability, null: false
			p.text :intellect_imagination, null: false
			p.boolean :dummy
			p.belongs_to :user
		end
  end
end
