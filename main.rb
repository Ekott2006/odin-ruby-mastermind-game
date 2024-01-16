COLORS = %w[Red Green Yellow Blue Purple Cyan].freeze

def colorize_text(text, text_color, background_color, bold = false, underline = false)
  style = []
  style << '1' if bold
  style << '4' if underline

  color_code = "#{style.join(';')};#{text_color};#{background_color}"

  "\e[#{color_code}m#{text}\e[0m"
end

def text_heading(text)
  puts "\n#{colorize_text(text, '30', '37', true, true)}"
end

def code_to_color(array, clues, add_clues = true)
  array.each do |value|
    i = COLORS.find_index(value)
    print "#{colorize_text("  #{i.to_i + 1}  ", '30', "#{41 + i.to_i}", true)} "
  end
  print ' Clues: ' if add_clues
  clues[0].times { print ' ● ' }
  clues[1].times { print ' ○ ' }
end
def normalise_user_input(text)

  text_to_array = text.gsub(/\d/) { |digit| "#{digit} " }.split(/\s+/)

  result = []
  lower_colors = COLORS.map(&:downcase)
  first_char_colors = COLORS.map { |value| value.downcase[0] }

  text_to_array.each do |value|
    index = lower_colors.find_index(value.downcase)
    i = first_char_colors.find_index(value.downcase)

    result << COLORS[index] unless index.nil?
    result << COLORS[i] if i && index.nil?
    result << COLORS[value.to_i - 1] if value.to_i.between?(1, 6)
  end

  result.length == 4 ? result : nil
end

def generate_mastermind_code
  Array.new(4) { COLORS.sample }
end

def evaluate_mastermind_guess(secret_array, testing_array)
  testing_array_copy = testing_array.dup
  result = [0, 0] # [Correct, Correct (wrong location)]

  secret_array.each_with_index do |value, i|
    result[0] += 1 if value == testing_array_copy[i]
  end

  secret_array.each do |value|
    i = testing_array_copy.find_index(value)
    result[1] += 1 unless i.nil?
    testing_array_copy.delete_at(i) unless i.nil?
  end

  result[1] -= result[0]
  result
end

def generate_all_mastermind_combinations
  COLORS.repeated_permutation(4).to_a
end

def handle_code_maker(master_code, max_guesses)
  possible_combinations = generate_all_mastermind_combinations
  guess = [COLORS[0], COLORS[0], COLORS[1], COLORS[1]]
  i = 0

  loop do
    i += 1
    result = evaluate_mastermind_guess(master_code, guess)
    possible_combinations.select! do |value|
      guess_result = evaluate_mastermind_guess(value, guess)
      guess_result[0] == result[0] && guess_result[1] == result[1]
    end
    puts "Computer Turn #{i}:"
    code_to_color(guess, result)
    puts "\n\n"

    if i >= max_guesses or guess == master_code
      puts "Game Over. The computer broke your code\n" if guess == master_code
      puts "You Win!!!. The computer failed to break your code\n" unless guess == master_code
      break
    end

    guess = possible_combinations.sample
  end
end

def handle_code_breaker(max_guesses)
  master_code = generate_mastermind_code
  guess = nil
  max_guesses.times do |i|
    while guess.nil?
      print "Turn #{i + 1}: Enter a valid code (e.g., 1123 or 'b b y c' or 'blue red cyan green'): "
      guess = normalise_user_input(gets.chomp)
    end
    result = evaluate_mastermind_guess(master_code, guess)

    code_to_color(guess, result)
    puts "\n\n"

    break if result[0] == 4

    guess = nil
  end
  puts "You Win!!!\n" if master_code == guess
  puts "You Lose. Try harder next time\n" unless master_code == guess
end

puts text_heading('MASTERMIND GAME')

puts text_heading('About')
puts 'This is a 1-player game against the computer.
You can choose to be the code maker or the code breaker.'

puts text_heading('Instruction')
puts 'The code maker makes a secret color combination, and the code breaker tries to guess it.'
puts 'After each guess, the code maker gives feedback about the correct colors and positions. '
puts 'The game goes on until the code breaker figures out the whole combination, using up to four clues marked with a check (●) for correct number and position and a circle (○) for correct number but wrong position.'

puts text_heading('Examples:')

# Six letters for master code
puts 'There are six different number/color combinations:'
COLORS.each_index { |i| print "#{colorize_text("  #{i + 1}  ", '30', (41 + i).to_s, true)} " }
puts "\nYou can also use their colors name"
COLORS.each_with_index { |value, i| print "#{colorize_text(value, '', (31 + i).to_s, true)} " }

puts "\n\nCODE MAKER"
# Four letters for master code
code_to_color(%w[Red Green Red Purple], [0, 0], false)

puts "\n\nCODE BREAKER"
# Four letters and clue
code_to_color(%w[Red Red Green Green], [1, 2])
puts "\nFor the 'secret code' above. The guess had 1 correct number in the correct position and 2 correct numbers in a wrong position."

loop do
  puts text_heading('Choose your role:')
  puts '1: Codemaker (create a secret code)'
  puts '2: Codebreaker (try to guess the secret code)'
  # User input
  print "Press '1' or '2' or 'q' to quit (any other key is 2): "
  option = gets.chomp
  break if option.downcase == 'q'

  print "Enter number of maximum guesses or 'q' to quit (any other key is 12): "
  max_guesses = gets.chomp
  break if max_guesses.downcase == 'q'
  max_guesses = max_guesses.to_i < 1 ? 12 : max_guesses.to_i

  # It its 1
  if option == '1'
    master_code = nil
    while master_code.nil?
      print "Enter a valid code (e.g., 1123 or 'b b y c' or 'blue red cyan green'): "
      master_code = normalise_user_input(gets.chomp)
    end
    handle_code_maker(master_code, max_guesses)
  else
    # If its 2
    handle_code_breaker(max_guesses)
  end

  # TODO: ENDING
  print "\nDo you want to play again? Press 'y' to continue or 'n' to quit (or any other key is 'y'): "
  break if gets.chomp.to_s.downcase == 'n'
end
