module ApplicationHelper
	def title
		"Ruby on Rails Tutorial Sample App" + (@title ? " | #{@title}" : "")
	end
end
