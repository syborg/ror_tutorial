module ApplicationHelper
	def title
		"Ruby on Rails Tutorial Sample App" + (@title ? " | #{@title}" : "")
	end

	def logo
		image_tag("logo.png", :alt => "Sample App", :class => "round")
	end

	# Dona informacio formatejada de les expessions que se li posin en una llista de strings separada per comes
	# Per exemple:
	# 	print_debug_expressions "image_path('/googleeyes.png')", "url_for 'assets/images/googleeyes.png'", "root_url+url_for('images/googleeyes.png')"
	def print_debug_expressions *args
		out = "<strong>PRINT DEBUG EXPRESSIONS</strong><br />"
		args.each do |arg|
			out << "#{arg.to_s} ==> <strong>#{eval(arg).to_s}</strong><br />"
		end 
		raw(out)	# MME des de Rails 3 la sortida s'escapeja amb h() per defecte, i per tant, s'ha de evitar aixo amb raw()
	end

end
