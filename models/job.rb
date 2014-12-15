class Job < ActiveRecord::Base
	# validations
	validates_presence_of :job_title
	validates_presence_of :satisfaction
	validates_presence_of :years_experience
	validates_presence_of :category
	validates_presence_of :salary

	# relationships
	belongs_to :user
end