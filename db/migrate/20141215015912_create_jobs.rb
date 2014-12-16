class CreateJobs < ActiveRecord::Migration
  def change
  	create_table :jobs do |j|
  		j.text :job_title, null: false
  		j.text :satisfaction, null: false
  		j.text :years_experience, null: false
  		j.text :category, null: false
  		j.text :salary, null: false
  		j.text :company
      j.belongs_to :user
  	end
  end
end
