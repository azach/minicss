#DESCRIPTION: 
# Minimizes a CSS file by stripping out all comments and blank lines
#
#NOTES:
# - Assumes any comment that has a beginning but no end comments out the 
# rest of the file
# - Comment markings can span multiple lines, e.g. we will strip comments like:
# /
# *
# this is a comment
# *
# /
# - Run-time is O(n) (one pass through the file is required)
# - Memory requirement is O(1) (only the current and next characters in the file are stored in memory)
# - Can also be done with RegEx, but memory requirement will be O(n)
# - For simplicity, this does not remove any extra line that has whitespace.
# This could be done by passing through the file again and reading it line by line, 
# stripping out whitespace only lines. This would leave the run-time as O(n), but worst 
# case memory is O(n) (the entire file on one line). Alternatively, we could look for
# whitespace between consecutive returns/line-feeds and then seek back in the file if
# a character is encountered, which would leave the memory requirement as O(1)
#
#USAGE: 
# minicss <input file name> <(optional) output filename>
#

#Description:
# Peeks at next non-whitespace character in the file
# Returns file to original position after reading from it
#Inputs:
# file - File to read from
#Returns:
# Next non-whitespace character from file
def get_next_char(file)
	orig = file.tell
	while true
		next_char = file.read(1)
		#End of file
		if (not next_char) 
			break
		#Not whitespace, so this is the next valid character
		elsif (not (next_char =~ /[\r|\t|\n|\f| ]/)) 
			break
		end
	end
	#Set file back to original position
	file.seek(orig, IO::SEEK_SET)
	return next_char
end

#Description:
# Outputs text to screen or file
#Inputs:
# char - Character to output
# file - File to output to, defaults to screen if null
def output(char, file)
	if (file != nil) 
		file.write(char)	
	else
		print(char)
	end
end

#Setup input parameters
def main
	if (ARGV.length < 1) 
		puts("Invalid arguments: Specify an input file")
		return
	elsif (ARGV.length > 2) 
		puts("Invalid arguments: Too many arguments provided")
		return
	end

	f = nil
	begin
		f = File.open(ARGV[0], "r")
	rescue
		puts("Could not open input file: #{ARGV[0]}")
		return
	end

	o = nil
	if (ARGV.length == 2) 
		begin
			o = open(ARGV[1], 'w')
		rescue
			puts("Could not open output file: #{ARGV[1]}")
			o = nil
		end
	end

	#Initialize character so we can read file line by line
	char = true

	#Set up counting variables to keep track of commented lines
	in_comment = false
	inner_comment_count = 0

	#Flag to keep track of whitespace
	last_char_was_newline = true

	#Read stream of characters
	while char
		char = f.getc
		next_char = get_next_char(f)
		#Found the beginning of a new comment
		if ((not in_comment) and (char == '/') and (next_char == '*')) 
			in_comment = true
			#Seek file past beginning of comment
			while(f.read(1) != '*')
				next
			end
		#Found the beginning of an inner comment
		elsif (in_comment and (char == '/') and (next_char == '*')) 
			inner_comment_count += 1
			while(f.read(1) != '*')
				next
			end
		#Found a comment that should end
		elsif in_comment and (char == '*') and (next_char == '/') 
			if (inner_comment_count > 0) 
				inner_comment_count -= 1
			else
				in_comment = false
			end
			while(f.read(1) != '/')
				next
			end
		#Finally, print out non-commented lines, skipping consecutive returns/linefeeds
		elsif not in_comment 
			curr_char_is_newline = (char =~ /[\r|\n]/)
			if not (curr_char_is_newline and last_char_was_newline) 
				output(char, o)
			end
			last_char_was_newline = curr_char_is_newline			
		end
	end
	
	f.close()

	if (o != nil) 
		o.close()
	end
end

if __FILE__ == $PROGRAM_NAME 
	main
end