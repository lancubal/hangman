class Hangman
  DICTIONARY_PATH = 'google-10000-english-no-swears.txt'
  MAX_INCORRECT_GUESSES = 6

  def initialize
    @secret_word = select_secret_word
    @incorrect_guesses = []
    @correct_guesses = []
    @remaining_incorrect_guesses = MAX_INCORRECT_GUESSES
    display_game_state
  end

  def secret_word
    @secret_word
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
      exit
    elsif @secret_word.chars.all? { |char| @correct_guesses.include?(char) }
      puts "Congratulations! You've guessed the word: #{@secret_word}"
      exit
    end
  end
end

game = Hangman.new
loop do
  puts "Enter a letter to guess:"
  letter = gets.chomp
  game.guess(letter)
end
