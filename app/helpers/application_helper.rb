module ApplicationHelper
	def title
		"Ruby on Rails Tutorial Sample App" + (@title ? " | #{@title}" : "")
	end

	def logo
		image_tag("logo.png", :alt => "Sample App", :class => "round")
	end
end
