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

import sys
import re

#Description:
# Peeks at next non-whitespace character in the file
# Returns file to original position after reading from it
#Inputs:
# file - File to read from
#Returns:
# Next non-whitespace character from file
def get_next_char(file):
	orig = file.tell()
	while (True):
		next_char = file.read(1)
		#End of file
		if not next_char:
			break
		#Not whitespace, so this is the next valid character
		if not re.match('[\r|\t|\n|\f| |]', next_char):
			break
			
	#Set file back to original position
	file.seek(orig, 0)
	
	return next_char

#Description:
# Outputs text to screen or file
#Inputs:
# char - Character to output
# file - File to output to, defaults to screen if null
def output(char, file):	
	if file is not None:
		file.write(char)	
	else:
		sys.stdout.write(char)

#Entry point
def main():
	#Setup input parameters
	if (len(sys.argv) < 2):
		print "Invalid arguments: Specify an input file"
		return

	if (len(sys.argv) > 3):
		print "Invalid arguments: Too many arguments provided"
		return
		
	f = None
	try:
		f = open(sys.argv[1], 'r')
	except:
		print "Could not open input file: " + sys.argv[1]
		return

	o = None
	if (len(sys.argv) == 3):
		try:
			o = open(sys.argv[2], 'w')
		except:
			print "Could not open output file: " + sys.argv[2]
			o = None
					
	#Initialize character so we can read file line by line
	char = True

	#Set up counting variables to keep track of commented lines
	in_comment = False
	inner_comment_count = 0

	#Flags to keep track of whitespace
	last_char_was_newline = True

	#Read stream of characters
	while char:	
		char = f.read(1)	
		next_char = get_next_char(f)
		#Found the beginning of a new comment
		if not in_comment and (char == '/') and (next_char == '*'):
			in_comment = True		
			#Seek file past beginning of comment
			while(f.read(1) != '*'): continue
		#Found the beginning of an inner comment
		elif in_comment and (char == '/') and (next_char == '*'):		
			inner_comment_count += 1
			while(f.read(1) != '*'): continue
		#Found a comment that should end
		elif in_comment and (char == '*') and (next_char == '/'):
			if (inner_comment_count > 0):
				inner_comment_count -= 1
			else:
				in_comment = False
			while(f.read(1) != '/'): continue
		#Finally, print out non-commented lines, skipping consecutive returns/linefeeds
		elif not in_comment:		
			curr_char_is_newline = re.match('[\r|\n]', char)
			if not (curr_char_is_newline and last_char_was_newline):
				output(char, o)
			last_char_was_newline = curr_char_is_newline

	f.close()

	if o is not None:
		o.close()
		
if __name__ == "__main__":
    main()		