class Hangman
  DICTIONARY_PATH = 'google-10000-english-no-swears.txt'
  MAX_INCORRECT_GUESSES = 6
  SAVE_DIR = 'saves'

  def initialize
    @secret_word = select_secret_word
    @incorrect_guesses = []
    @correct_guesses = []
    @remaining_incorrect_guesses = MAX_INCORRECT_GUESSES
    @save_file = nil
    display_game_state
  end

  def guess(letter)
    letter.downcase!
    if @secret_word.include?(letter)
      @correct_guesses << letter unless @correct_guesses.include?(letter)
    else
      @incorrect_guesses << letter unless @incorrect_guesses.include?(letter)
      @remaining_incorrect_guesses -= 1
    end
    display_game_state
    check_game_over
  end

  def display_game_state
    display_word = @secret_word.chars.map { |char| @correct_guesses.include?(char) ? char : '_' }.join(' ')
    puts "Word: #{display_word}"
    puts "Incorrect guesses: #{@incorrect_guesses.join(', ')}"
    puts "Remaining incorrect guesses: #{@remaining_incorrect_guesses}"
    draw_stickman
  end

  def draw_stickman
    parts = [
      " O ", # head
      " | ", # body
      "/| ", # one arm
      "/|\\", # both arms
      "/  ", # one leg
      "/ \\" # both legs
    ]

    stickman = [
      " +---+",
      " |   |",
      "     |",
      "     |",
      "     |",
      "     |",
      "======"
    ]

    parts_to_draw = parts[0, MAX_INCORRECT_GUESSES - @remaining_incorrect_guesses]

    stickman[2] = " #{parts_to_draw[0]}" if parts_to_draw[0]
    stickman[3] = " #{parts_to_draw[1]}" if parts_to_draw[1]
    stickman[3] = "#{parts_to_draw[2]}" if parts_to_draw[2]
    stickman[3] = "#{parts_to_draw[3]}" if parts_to_draw[3]
    stickman[4] = " #{parts_to_draw[4]}" if parts_to_draw[4]
    stickman[4] = "#{parts_to_draw[5]}" if parts_to_draw[5]

    stickman.each { |line| puts line }
  end

  def save_game(filename)
    Dir.mkdir(SAVE_DIR) unless Dir.exist?(SAVE_DIR)
    File.open("#{SAVE_DIR}/#{filename}", 'wb') { |file| Marshal.dump(self, file) }
    @save_file = filename
    puts "Game saved as #{filename}!"
  end

  def self.load_game(filename)
    if File.exist?("#{SAVE_DIR}/#{filename}")
      game = File.open("#{SAVE_DIR}/#{filename}", 'rb') { |file| Marshal.load(file) }
      game.instance_variable_set(:@save_file, filename)
      game
    else
      puts "No saved game found with the name #{filename}."
      new
    end
  end

  private

  def load_dictionary
    File.readlines(DICTIONARY_PATH).map(&:chomp)
  end

  def select_secret_word
    words = load_dictionary.select { |word| word.length.between?(5, 12) }
    words.sample
  end

  def check_game_over
    if @remaining_incorrect_guesses <= 0
      puts "Game over! The word was: #{@secret_word}"
      delete_save_file
      exit
    elsif @secret_word.chars.all? { |char| @correct_guesses.include?(char) }
      puts "Congratulations! You've guessed the word: #{@secret_word}"
      delete_save_file
      exit
    end
  end

  def delete_save_file
    return unless @save_file

    if File.exist?("#{SAVE_DIR}/#{@save_file}")
      File.delete("#{SAVE_DIR}/#{@save_file}")
      puts "Save file #{@save_file} deleted."
    else
      puts "No save file found with the name #{@save_file}."
    end
  end
end

puts "Welcome to Hangman!"
puts "1. Start a new game"
puts "2. Load a saved game"
choice = gets.chomp

if choice == '2'
  if Dir.exist?(Hangman::SAVE_DIR)
    save_files = Dir.entries(Hangman::SAVE_DIR).select { |f| !File.directory? f }
    if save_files.empty?
      puts "No saved games available."
      game = Hangman.new
    else
      puts "Available saved games:"
      save_files.each_with_index { |file, index| puts "#{index + 1}. #{file}" }
      puts "Enter the number of the save file to load:"
      file_choice = gets.chomp.to_i
      filename = save_files[file_choice - 1]
      game = Hangman.load_game(filename)
    end
  else
    puts "No saved games available."
    game = Hangman.new
  end
else
  game = Hangman.new
end

loop do
  puts "Enter a letter to guess or type 'save' to save the game:"
  input = gets.chomp
  if input.downcase == 'save'
    puts "Enter a name for your save file:"
    filename = gets.chomp
    game.save_game(filename)
  else
    game.guess(input)
  end
end
