#Author: Reagan Duggins
#This program reads a .csv file that contains members of a choir and their stats, and sorts
#  them into a suggested order. Then translates the sorted choir into a printable .txt file that
#is formatted to give the choir director a sheet of 9 small cards containing the stats of each
#  member.
#### page width is 97 chars, but use 96
#### height is 52 lines
class ChoirMaker
	
###############################
#   Initialization and Such
###############################

	attr_accessor :singers,:choir,:out_file,:longest_name
	def initialize
		@singers = {
			"a1" => [],
			"a2" => [],
			"b1" => [],
			"b2" => [],
			"s1" => [],
			"s2" => [],
			"t1" => [],
			"t2" => []
		}
		@choir = []
		#change this to be given by user
		@out_file = File.new('blurf.txt','w')
		@longest_name = 0
	end

	# This class is designed hold the data for a singer for easy sorting and stuff
	class Singer
		attr_accessor :name, :height, :voice_type, :vocal_color, :needs

		def initialize name='noname',height=0,voicetype='novoice',vocalcolor='nocolor',needs='noneeds'
			@name = name
			@height = height
			@voice_type = voicetype
			@vocal_color = vocalcolor
			@needs = needs
		end
		
		def to_s
			"#{name}\n   #{height}in\n   #{voice_type}\n   Has a #{vocal_color} voice\n   Needs: #{needs}"
		end

	end
	
################################
#	Main Methods
################################

	def get_input_file
		#get the file to read through
		##this will add a .csv extension if no extension is provided
		filename = ""
		while filename == ""
			print 'Please enter filename (or "exit" without the quotes to exit): '
			filename = gets.chomp                                   # get the filename
			abort if filename.downcase == 'exit'                    # if they type exit then exit the program
			filename += ".csv" if !filename.include? '.'            # if there's no extension then add .csv
			
			#check if it is a working filename, if not then keep looping
			begin
				in_file = File.new(filename)
			rescue
				puts "Error: Could not open a file by that name!"
				filename = ""
			end
		end
	end


	def get_singers(in_file)

		#this section will do the calculations on the chart unless the user typed "exit" in the input loop above

		#go through each line
		first_line = true                      # this assumes that the first line of the .csv file is just lables for columns
		in_file.each do |line|

			#this if block assumes that the first line is column lables, comment it out if you know otherwise
			if first_line
				first_line = false
				next
			end
			
			#line is going to be an entire csv line
			#so we will split it into an array of individual stats
			
			stats = line.split(',')
			@singers[stats[2].downcase].push Singer.new(stats[0],stats[1],stats[2].downcase,stats[3],stats[4])
			@singers.values.each do |vtype|
				vtype.sort_by! do |s|
					#sort the singers within each voice type by height
					s.height
				end.reverse! #reverse the sorted array because it sorts backwards for some reason
			end
		end
		@longest_name = longest_name_length
	end

	
	def make_choir
		#need to add multiple choir formations
		#basic strategy for this is as follows:
		#	ask how many singers wide they want each section
		#   then have a 2d array for each voice type that you fill with singers in order of height (so that taller people will be in back
		#   then figure out how to format the choir, then join the arrays appropriately
		
		
		##side note: cols == width (conceptually) and rows == depth (conceptually)
		
		
		
		puts "Which formation would you like for your choir? (0: none, 1: standard)"
		formation = gets.chomp.to_i rescue 0
		case formation
		when 1 
			# I call this the standard formation, it is where (from the conductor's point of view) the sopranos are on the far left, the basses just to the right of them, then the tenors,
			# and then the altos on the far right. Also, this has the 1's behind the 2's
			##there is probably a more streamlined way to do this...
			puts "How many singers wide is the soprano section?"
			width_s = gets.to_i rescue 1
			
			puts "How many singers wide is the bass section?"
			width_b = gets.to_i rescue 1
			
			puts "How many singers wide is the tenor section?"
			width_t = gets.to_i rescue 1
			
			puts "How many singers wide is the alto section?"
			width_a = gets.to_i rescue 1
			
			choir_width = width_s + width_b + width_t + width_a
			
			choir = []
			(0...choir_width).each do |i|
				choir.push []
				(0...width_s).each do |j|
					if !singers['s1'].empty?
						choir[i].push singers['s1'].shift
					elsif !singers['s2'].empty?
						choir[i].push singers['s2'].shift
					else
						choir[i].push ''
					end
				end
				(0...width_b).each do |j|
					if !singers['b1'].empty?
						choir[i].push singers['b1'].shift
					elsif !singers['b2'].empty?
						choir[i].push singers['b2'].shift
					else
						choir[i].push ""
					end
				end
				(0...width_t).each do |j|
					if !singers['t1'].empty?
						choir[i].push singers['t1'].shift
					elsif !singers['t2'].empty?
						choir[i].push singers['t2'].shift
					else
						choir[i].push ''
					end
				end
				(0...width_a).each do |j|
					if !singers['a1'].empty?
						choir[i].push singers['a1'].shift
					elsif !singers['a2'].empty?
						choir[i].push singers['a2'].shift
					else
						choir[i].push ''
					end
				end
			end
			
			puts "\n"
			print_choir choir
			
			puts "Would you like to save this choir?(y/n)"
			ans = gets.chomp.downcase
			if ans == "y"
				#if they want to save it, then write it to a file
				puts "What do you want to name this choir?(without extension)"
				outfname = gets.chomp.split(/\W/).join("")
				outf = File.open(outfname + '.txt', 'w')
				puts "Saving as #{outfname}.txt..."
				write_choir(choir,outf)
			end
			#There may be a more flexible way to do this...
		
			return choir
		else
		### else is going to be if 0 or anything other than the suggested formations is selected
			puts "Mixed choir formation is still under production!"
		end
	end
	
	
###############################
#    Choir Helper Methods     #
###############################
	
	def print_choir(choir)
		choir.each do |k|
			k.each do |s|
				#print the first name
				if s.class == Singer
					print "| #{s.name}, #{s.voice_type} |"    #ask how this should be displayed
				else
					print "| EmptySeat |"
				end
			end
			puts ""
		end
	end
	
	def write_choir(choir,out_file=File.new("new_choir.txt"))
		choir.each do |k|
			next if (k == nil || k.length == 0 || k.reject{ |x| x == nil || x == ''}.length == 0)
			(24*choir.length).times{ out_file.print "#" }
			out_file.print "\n"
			k.each do |s|
				#print the name
				if s.class == Singer
					name = s.name
					name = "" if name == nil
					out_file.print '#'
					((22-name.length)/2).floor.to_i.times { out_file.print " " }  #leading spaces
					out_file.print name.chomp
					((22-name.length)/2).floor.to_i.times { out_file.print " " }  #trailing spaces
					out_file.print " " if ((22-name.length)/2).floor*2 + name.length < 22    #sometimes there are one too few spaces
					out_file.print '#'
				else
					out_file.print "#      Empty  Seat     #"
				end
			end
			out_file.print "\n"
			k.each do |s|
				#print the voice type
				if s.class == Singer
					out_file.print '#'
					((22-s.voice_type.length)/2).floor.to_i.times { out_file.print " " }  #leading spaces
					out_file.print s.voice_type.chomp
					((22-s.voice_type.length)/2).floor.to_i.times { out_file.print " " }  #trailing spaces
					out_file.print " " if ((22-s.voice_type.length)/2).floor*2 + s.voice_type.length < 22    #sometimes there are one too few spaces
					out_file.print '#'
				else
					out_file.print "#                      #"
				end
			end
			out_file.print "\n"
		end
		(24*choir.length).times{ out_file.print "#" }
	end
	
	def longest_name_length
		#this searches @singers and returns the length of the longest name
		longest = 0
		singers.each do |k,v|
			v.each do |s|
				longest = s.name.length if s.name.length > longest
			end
		end
		return longest
	end
	
	
end
c = ChoirMaker.new
c.get_singers(File.new('choir.csv','r'))
x = c.make_choir

