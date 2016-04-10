
class School

	attr_accessor :code, :name, :type, :students, :score
	

	def initialize(code, name, type, students, score)

		@code, @name, @type, @students, @score = code, name, type, students, score
	end

end