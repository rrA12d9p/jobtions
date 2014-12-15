class Personality < ActiveRecord::Base
	# validations
	validates_presence_of :extraversion
	validates_presence_of :agreeableness
	validates_presence_of :conscientiousness
	validates_presence_of :emotional_stability
	validates_presence_of :intellect_imagination

	# relationships
	belongs_to :user
end