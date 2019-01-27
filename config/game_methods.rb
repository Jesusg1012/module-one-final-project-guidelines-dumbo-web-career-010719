
#-----------------------------------------------------------------------#
#---------------------------- Main Menu --------------------------------#
#-----------------------------------------------------------------------#
def banner
  puts "

  ███████╗██╗      █████╗ ████████╗██╗██████╗  ██████╗ ███╗   ██╗
  ██╔════╝██║     ██╔══██╗╚══██╔══╝██║██╔══██╗██╔═══██╗████╗  ██║
  █████╗  ██║     ███████║   ██║   ██║██████╔╝██║   ██║██╔██╗ ██║
  ██╔══╝  ██║     ██╔══██║   ██║   ██║██╔══██╗██║   ██║██║╚██╗██║
  ██║     ███████╗██║  ██║   ██║   ██║██║  ██║╚██████╔╝██║ ╚████║
  ╚═╝     ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝

  ██████╗  █████╗ ████████╗██╗███╗   ██╗ ██████╗     ███████╗██╗███╗   ███╗
  ██╔══██╗██╔══██╗╚══██╔══╝██║████╗  ██║██╔════╝     ██╔════╝██║████╗ ████║
  ██║  ██║███████║   ██║   ██║██╔██╗ ██║██║  ███╗    ███████╗██║██╔████╔██║
  ██║  ██║██╔══██║   ██║   ██║██║╚██╗██║██║   ██║    ╚════██║██║██║╚██╔╝██║
  ██████╔╝██║  ██║   ██║   ██║██║ ╚████║╚██████╔╝    ███████║██║██║ ╚═╝ ██║
  ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝╚═╝  ╚═══╝ ╚═════╝     ╚══════╝╚═╝╚═╝     ╚═╝

  "
  sleep(3)
  system "clear"
end

def welcome
  main_menu = [
    {"New Game" => -> do new_game end },
    {"Load Game" => -> do load_game end},
    {"Delete File" => -> do delete_file end},
    {"Exit" => -> do goodbye end}]
  prompt = TTY::Prompt.new
  response = prompt.select("Welcome to the Flatiron Dating Sim!", main_menu)
  welcome
end

def new_game
  puts "What is your name?"
  name = gets.chomp
  prompt = TTY::Prompt.new
  preference = prompt.select("What is your sexual preference?", %w(Male Female Both))
  current_user = User.create(name: name, preference: preference,
    fitness: rand(0..15), intellect: rand(0..15), kindness: rand(0..15),
    money: 100, total_days: 0, work_days: 0, volunteer_days: 0, total_dates: 0, gym_days: 0, study_days: 0)
    goal_message
    display_stats(current_user)
    sleep(2)
    system "clear"
    day(current_user)
  end

def goodbye
  puts "Goodbye!"
  sleep(2)
  system "clear"
  exit
end

def load_game
  if User.all.length == 0
    puts "There are no more files!"
    sleep(1)
    system "clear"
    return nil
  end
  user_choices = User.all.map{ |obj| obj.name}
  prompt = TTY::Prompt.new
  choice = prompt.select("Choose a file", user_choices)
  current_user = User.all.find { |obj| obj.name == choice}
  puts "You've chosen #{current_user.name}"
  sleep(1)
  if current_user.total_days == 0
    system "clear"
    goal_message
  end
  system "clear"
  day(current_user)
end

  def delete_file
    if User.all.length == 0
      puts "There are no more files!"
      sleep(1)
      return nil
    end
    users = User.all.map { |obj| obj.name}
    prompt = TTY::Prompt.new
    delete_choice = prompt.select("Choose a file to delete", users)
    deleting = User.all.find { |obj| obj.name == delete_choice}
    if Dates.all.length != 0
      Dates.where(user_id: deleting.id).delete_all
    end
    deleting.destroy
    puts "File has been deleted."
    sleep(1)
    system "clear"
    welcome
  end
#-----------------------------------------------------------------------#
#---------------------------- Day Loops --------------------------------#
#-----------------------------------------------------------------------#

def day(current_user, action_point = 0)
  current_user.save
  choices = [
    {name: 'Go to work', value: 1},
    {name: 'Hit the gym', value: 2},
    {name: 'Volunteer', value: 3},
    {name: 'Study at the library', value:4},
    {name: 'Text someone', value: 5},
    {name: 'Go on a date', value: 6},
    {name: 'Check your journal', value: 7},
    {name: 'Exit', value: 8}]
  if current_user.total_days == 0
    choices[4][:disabled] = "(You haven't met anyone to talk to!)"
    choices[5][:disabled] = "(You haven't met anyone to talk to!)"
  end
  if action_point > 0
    choices[5][:disabled] = "(Not enough time in the day!)"
  end
  if action_point > 1
    choices[0][:disabled] = "(You missed your shift!)"
  end
  if action_point > 2
    choices[2][:disabled] = "(Not enough time in the day!)"
  end

  display_stats(current_user)
  prompt = TTY::Prompt.new
  answer = prompt.select("Day #{current_user.total_days + 1} - What do you want to do?", choices)
  if answer == 1
    work(current_user)
    action_point +=3
  elsif answer == 2
    gym(current_user)
    action_point += 1
  elsif answer == 3
    volunteer(current_user)
    action_point +=2
  elsif answer == 4
    study(current_user)
    action_point += 1
  elsif answer == 5
    flirt(current_user)
    action_point += 1
  elsif answer == 6
    check = date(current_user)
    if check != "no date"
      action_point += 4
    end
  elsif answer == 7
    diary(current_user)
  elsif answer == 8
    system "clear"
    return welcome
  end
  if check == "won" || check == "lose"
    return welcome
  end
  if action_point == 4
    sleep(1)
    puts "Wow, today was tiring. Time to go to bed!"
    sleep(1)
    current_user.total_days += 1
    action_point = 0
  end
  back = [
    {"continue" => -> do puts "ok" end } ]
      prompt = TTY::Prompt.new
      prompt.select("Click continue when you are finished reading", back)
    system "clear"
    day(current_user, action_point)
end

#----------------------------------------------------------------------------#
#---------------------------- Action Methods --------------------------------#
#----------------------------------------------------------------------------#

def diary(current_user)
  puts "Facts:"
  if Dates.all.find{|user| user.user_id == current_user.id} != nil
    Dates.all.each do |date|
      if date.user_id == current_user.id
        lover_max = 0
        lover = Lover.all.find{|lover1| lover1.id == date.lovers_id}
        puts " "
        puts "#{Lover.all.find{|lover1| (lover_max = lover1.aff_pts_req); lover1.id == date.lovers_id}.name}: #{date.affection_pts}/#{lover_max} affection points"
        if date.fact_color !=nil
          puts "color: #{date.fact_color}"
        end
        if date.fact_season != nil
          puts "season: #{date.fact_season}"
        end
        if date.fact_dream != nil
          puts "dream: #{date.fact_dream}"
        end
        if date.fact_item != nil
          puts "item: #{date.fact_item}"
        end
        if date.fact_place != nil
          puts "place: #{date.fact_place}"
        end
        if date.fact_food != nil
          puts "food: #{date.fact_food}"
        end
      end
    end
  end
end

def work(current_user)
  pid = fork{ exec 'afplay', "./sounds/work-sound.mp3" }
  if current_user.work_days == 0
    if current_user.preference == 'Both'
      lover = Lover.all.select { |lovers| lovers.interest == "money" }
      puts "You have met #{lover[0].name} & #{lover[1].name}!"
      puts lover[0].first_meeting
      puts lover[1].first_meeting
      sleep(1)
      bisexual_meet_check(current_user, lover)
    else
      lover = Lover.all.find {|lovers|lovers.gender == current_user.preference && lovers.interest == "money"}
      puts "You have met #{lover.name}!"
      puts lover.first_meeting
      sleep(1)
      user_meet_check(current_user, lover)
    end
  end
  puts "Another day, another dollar."
  sleep(1)
  current_user.money += 200

  current_user.save
  current_user.work_days += 1
end

def gym(current_user)
  pid = fork{ exec 'afplay', "./sounds/gym-sound.mp3" }
  if current_user.gym_days == 0
    if current_user.preference == 'Both'
      lover = Lover.all.select { |lovers| lovers.interest == "fitness" }
      puts "You have met #{lover[0].name} & #{lover[1].name}!"
      puts lover[0].first_meeting
      puts lover[1].first_meeting
      sleep(2)
      bisexual_meet_check(current_user, lover)
    else
      lover = Lover.all.find {|lovers| lovers.gender == current_user.preference && lovers.interest == "fitness"}
      puts "You have met #{lover.name}!"
      puts lover.first_meeting
      sleep(2)
      user_meet_check(current_user, lover)
    end
  end
  puts "I'm so sore."
  sleep(1)
  current_user.fitness += 10

  current_user.save
  current_user.gym_days += 1
end

def volunteer(current_user)
  pid = fork{ exec 'afplay', "./sounds/volunteer-sound.wav" }
  if current_user.volunteer_days == 0
    if current_user.preference == 'Both'
      lover = Lover.all.select { |lovers| lovers.interest == "volunteering" }
      puts "You have met #{lover[0].name} & #{lover[1].name}!"
      puts lover[0].first_meeting
      puts lover[1].first_meeting
      sleep(1)
      bisexual_meet_check(current_user, lover)
    else
      lover = Lover.all.find {|lovers|lovers.gender == current_user.preference && lovers.interest == "volunteering"}
      puts "You have met #{lover.name}!"
      puts lover.first_meeting
      sleep(1)
      user_meet_check(current_user, lover)
    end
  end
  puts "The shelter looks slighter nicer now!"
  sleep(1)
  current_user.kindness += 10

  current_user.save
  current_user.volunteer_days += 1
end

def study(current_user)
  pid = fork{ exec 'afplay', "./sounds/study-sound.wav" }
  if current_user.study_days == 0
    if current_user.preference == 'Both'
      lover = Lover.all.select { |lovers| lovers.interest == "intellect" }
      puts "You have met #{lover[0].name} & #{lover[1].name}!"
      puts lover[0].first_meeting
      puts lover[1].first_meeting
      sleep(1)
      bisexual_meet_check(current_user, lover)
    else
      lover = Lover.all.find {|lovers|lovers.gender == current_user.preference && lovers.interest == "intellect"}
      puts "You have met #{lover.name}!"
      puts lover.first_meeting
      sleep(1)
      user_meet_check(current_user, lover)
    end
  end
  puts "Ugh... Learning Active Record is confusing..."
  sleep(1)
  current_user.intellect += 10

  current_user.save
  current_user.study_days += 1
end

def flirt(current_user)
  pid = fork{ exec 'afplay', "./sounds/flirt_sound.mp3" }
  prompt = TTY::Prompt.new
  lovers = true_names(current_user)
  choice = prompt.select("Who do you want to flirt with?", lovers)
  choice_id = Lover.all.find { |lovers| lovers.name == choice }
  pts = affection_adder(current_user, Lover.first)
  sleep(1)
  if Dates.all.find{|d| d.user_id == current_user.id && d.lovers_id == choice_id.id } == nil
    current_date = Dates.create(user_id: current_user.id, affection_pts: pts, lovers_id: choice_id.id)
  else
    current_date = Dates.all.find{|d| d.user_id == current_user.id && d.lovers_id == choice_id.id }
  end
  current_date.affection_pts += pts
  current_date.save
  if current_date.fact_color == nil
    current_date.fact_color = choice_id.fact_color
    puts "#{choice}: #{choice_id.fact_color}"
  elsif current_date.fact_season == nil
      current_date.fact_season = choice_id.fact_season
      puts "#{choice}: #{choice_id.fact_season}"
  elsif current_date.fact_dream == nil
      current_date.fact_dream = choice_id.fact_dream
      puts "#{choice}: #{choice_id.fact_dream}"
  elsif current_date.fact_item == nil
      current_date.fact_item = choice_id.fact_item
      puts "#{choice}: #{choice_id.fact_item}"
  elsif current_date.fact_place == nil
      current_date.fact_place = choice_id.fact_place
      puts "#{choice}: #{choice_id.fact_place}"
  elsif current_date.fact_food == nil
      current_date.fact_food = choice_id.fact_food
      puts "#{choice}: #{choice_id.fact_food}"
  end
  sleep(1)
  puts "You got to know #{choice} better!"
  sleep(1)
  current_date.save
end


#----------------------------------------------------------------------------#
#---------------------------- Helper Methods --------------------------------#
#----------------------------------------------------------------------------#

def prompt_facts(choice_id)
  facts = [choice_id.fact_food, choice_id.fact_item, choice_id.fact_place, choice_id.fact_color, choice_id.fact_dream, choice_id.fact_season]
  facts.sample
end

def goal_message
  system "clear"
  puts "Hey there!"
  sleep(1)
  puts "Welcome to the Flatiron School, we're really glad to have you!"
  sleep(1)
  puts "There is going to be a school dance in exactly..."
  sleep(1)
  puts "30 DAYS!!!??"
  sleep(1)
  puts "You need to find a date to go with!!"
  puts "Good luck!!"
  sleep(3)
  system "clear"
end

def display_stats(current_user)
  puts "Here are your stats.
  Fitness: #{current_user.fitness}
  Intellect: #{current_user.intellect}
  Kindness: #{current_user.kindness}
  Money: $#{current_user.money}"
end

def affection_adder(current_user, current_lover)
  fitness_mod = current_user.fitness * current_lover.aff_fitness_mod
  intellect_mod = current_user.intellect * current_lover.aff_intellect_mod
  kindness_mod = current_user.kindness * current_lover.aff_kindness_mod
  money_mod = current_user.money / current_lover.aff_money_mod
  aff_pts = (fitness_mod + intellect_mod + kindness_mod + money_mod)/5
end

def date (current_user)
  prompt = TTY::Prompt.new
  choices = true_names(current_user)
  choice = prompt.select("Who do you want to go on a date with?", choices)
  choice_id = Lover.all.find { |lovers| lovers.name == choice }
  pts = affection_adder(current_user, choice_id)
  date = Dates.all.find{|d| d.user_id == current_user.id && d.lovers_id == choice_id.id}
  if  date != nil && current_user.fitness >= choice_id.fitness_req && current_user.intellect >= choice_id.intellect_req && current_user.kindness >= choice_id.kindness_req && current_user.money >= choice_id.money_req
    date.affection_pts += date_test(current_user, date, choice_id, choice) * (pts/2)
    current_user.money -= choice_id.money_req
    current_user.total_dates += 1
    current_user.save
    date.save
    if date.affection_pts >= choice_id.aff_pts_req
        puts "#{choice_id.name} wants to be exclusive with you."
        return endgame(current_user, choice_id)
    end
  else
    puts "#{choice} doesn't seem interested in going on a date with you."
    sleep(2)
    return "no date"
  end
  sleep(1)
end

def lose_game(current_user)
  system "clear"
  sleep(3)
  pid = fork{ exec 'afplay', "./sounds/Lose.mp3"}
  puts "Wow..."
  sleep(1)
  puts "Today's the day of Prom and you couldn't find a date..."
  sleep(1)
  puts "What's the point of even going alone?"
  sleep(1)
  puts "You're such a

    ██▓     ▒█████    ██████ ▓█████  ██▀███
  ▓██▒    ▒██▒  ██▒▒██    ▒ ▓█   ▀ ▓██ ▒ ██▒
  ▒██░    ▒██░  ██▒░ ▓██▄   ▒███   ▓██ ░▄█ ▒
  ▒██░    ▒██   ██░  ▒   ██▒▒▓█  ▄ ▒██▀▀█▄
  ░██████▒░ ████▓▒░▒██████▒▒░▒████▒░██▓ ▒██▒
  ░ ▒░▓  ░░ ▒░▒░▒░ ▒ ▒▓▒ ▒ ░░░ ▒░ ░░ ▒▓ ░▒▓░
  ░ ░ ▒  ░  ░ ▒ ▒░ ░ ░▒  ░ ░ ░ ░  ░  ░▒ ░ ▒░
   ░ ░   ░ ░ ░ ▒  ░  ░  ░     ░     ░░   ░
     ░  ░    ░ ░        ░     ░  ░   ░

                                          "
  sleep(1)
  options = [
    {"Reset Game?" => -> do reset_character(current_user) end },
    {"Delete File" => -> do delete_self(current_user) end}]
  prompt = TTY::Prompt.new
  response = prompt.select("What will you do?", options)
  puts "Let's try this again."
  sleep(3)
  system "clear"
  return welcome
end

def endgame(current_user, lover)
  pid = fork{ exec 'afplay', "./sounds/Smang-It.mp3"}
  system "clear"
  puts "
  ██████╗ ██████╗ ███╗   ██╗ ██████╗ ██████╗  █████╗ ████████╗███████╗
 ██╔════╝██╔═══██╗████╗  ██║██╔════╝ ██╔══██╗██╔══██╗╚══██╔══╝██╔════╝
 ██║     ██║   ██║██╔██╗ ██║██║  ███╗██████╔╝███████║   ██║   ███████╗
 ██║     ██║   ██║██║╚██╗██║██║   ██║██╔══██╗██╔══██║   ██║   ╚════██║
 ╚██████╗╚██████╔╝██║ ╚████║╚██████╔╝██║  ██║██║  ██║   ██║   ███████║
  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝
    "
  puts "Congratulations! You found someone to go to Prom with!"
  puts "It took you
  #{current_user.total_days} total days
  #{current_user.work_days} work sessions
  #{current_user.volunteer_days} volunteer sessions
  #{current_user.gym_days} gym sessions
  #{current_user.study_days} study sessions
  #{current_user.total_dates} total dates
  to end up with #{lover.name}"
  puts "Thank you for playing Flatiron Dating Sim!"
  sleep(3)
  reset_character(current_user)
  sleep(4)
  return welcome
end

def reset_character(current_user)
  User.update(current_user.id, fitness: rand(0..15), intellect: rand(0..15), kindness: rand(0..15),
    money: 100, total_days: 0, work_days: 0, volunteer_days: 0, total_dates: 0, gym_days: 0, study_days: 0,
   nikki: nil, kira: nil, princess: nil, penelope: nil, ryan: nil, john: nil, fabio: nil, oliver: nil)
  Dates.where(user_id: current_user.id).delete_all
  puts "You can continue to play the game, but your stats have been reset."
end

def delete_self(current_user)
  User.find(current_user.id).destroy
  Dates.where(user_id: current_user.id).delete_all
  puts "Your file has been deleted"
end

def user_meet_check(current_user, lover)
  if lover.name == "Nikki"
    current_user.nikki = true
  elsif lover.name == "Kira"
    current_user.kira = true
  elsif lover.name == "Princess"
    current_user.princess = true
  elsif lover.name == "Penelope"
    current_user.penelope = true
  elsif lover.name == "Ryan"
    current_user.ryan = true
  elsif lover.name == "John"
    current_user.john = true
  elsif lover.name == "Fabio"
    current_user.fabio = true
  elsif lover.name == "Oliver"
    current_user.oliver = true
  end
end

def true_names(current_user)
  arr = []
  if current_user.nikki == true
      arr << "Nikki"
  end
  if current_user.kira == true
      arr << "Kira"
  end
  if current_user.princess == true
    arr << "Princess"
  end
  if current_user.penelope == true
    arr << "Penelope"
  end
  if current_user.ryan == true
    arr << "Ryan"
  end
  if current_user.john == true
    arr << "John"
  end
  if current_user.fabio == true
    arr << "Fabio"
  end
  if current_user.oliver == true
    arr << "Oliver"
  end
  arr
end

def bisexual_meet_check(current_user, lovers)
  lovers.each do |obj|
    user_meet_check(current_user, obj)
  end
end

def date_test(current_user, current_date, lover_id, lover_name)
  arr = ["food", "dream", "color", "place", "item", "season"]
  lover_questions = date_questions()
  check = 0
  puts "You are on a date with #{lover_name}! Make sure you remember #{lover_name}'s facts."
  sleep(2)
  rand(2..6).times do
  question_asked = arr.sample
  if question_asked == "dream"
    puts lover_questions[lover_name][:fact_dream]
    answer = gets.chomp
    if lover_id.fact_dream.downcase.include?(answer.downcase)
      check += 5
      puts "Correct!"
      sleep(1)
    else
      puts "Wrong!"
      sleep(1)
      check -= 5
    end
  elsif question_asked == "place"
    puts lover_questions[lover_name][:fact_place]
    answer = gets.chomp
    if lover_id.fact_place.downcase.include?(answer.downcase)
      check += 5
      puts "Correct!"
      sleep(1)
    else
      puts "Wrong!"
      sleep(1)
      check -= 5
    end
  elsif question_asked == "item"
    puts lover_questions[lover_name][:fact_item]
    answer = gets.chomp
    if lover_id.fact_item.downcase.include?(answer.downcase)
      check += 5
      puts "Correct!"
      sleep(1)
    else
      puts "Wrong!"
      sleep(1)
      check -= 5
    end
  elsif question_asked == "food"
    puts lover_questions[lover_name][:fact_food]
    answer = gets.chomp
    if lover_id.fact_food.downcase.include?(answer.downcase)
      check += 5
      puts "Correct!"
      sleep(1)
    else
      puts "Wrong!"
      sleep(1)
      check -= 5
    end
  elsif question_asked == "color"
    puts lover_questions[lover_name][:fact_color]
    answer = gets.chomp
    if lover_id.fact_color.downcase.include?(answer.downcase)
      check += 5
      puts "Correct!"
      sleep(1)
    else
      puts "Wrong!"
      sleep(1)
      check -= 5
    end
  elsif question_asked == "season"
    puts lover_questions[lover_name][:fact_season]
    answer = gets.chomp
    if lover_id.fact_season.downcase.include?(answer.downcase)
      check += 5
      puts "Correct!"
      sleep(1)
    else
      puts "Wrong!"
      sleep(1)
      check -= 5
    end
  end
end
puts "You got #{check} affection points."
  if check <= 0
    puts "Your date sucked!"
  else
    puts "Your date was alot of fun!"
  end
  sleep(2)
  return check
end

def date_questions
  question = {
    "Nikki" => {
    :fact_dream => "Do you remember what my biggest dream is?",
    :fact_color => "What's my favorite color?",
    :fact_place => "You can always find me here",
    :fact_item => "Can you buy this for me?",
    :fact_food =>"Guess what my favorite food is!",
    :fact_season => "My favorite time of year is probably..."
    },
    "Kira" => {
      :fact_dream => "Have I told you what my dream is?",
      :fact_color => "Have you noticed what my favorite color is?",
      :fact_place => "If I could travel somewhere, where would it be?",
      :fact_item => "I really love...",
      :fact_food => "What kind of food should we get?",
      :fact_season => "Do you remember what my favorite season is?"
    },
    "Princess" => {
      :fact_dream => "What kind of car would you buy for me?",
      :fact_color => "I told you I wanted this in A SPECIFIC COLOR. Do you even remember what color I said?",
      :fact_place => "My dream house is...",
      :fact_item => "I really want thissssss purse. Do you remember which one I wanted??",
      :fact_food => "I'm hungry!! Where are we eating?",
      :fact_season => "Next season's fashion show is my favorite season. Do you know what season I'm talking about??"
    },
    "Penelope" => {
      :fact_dream => "Wouldn't it be crazy if I got to meet this person?? Can you guess who??",
      :fact_color => "is it obvious that my favorite color is...",
      :fact_place => "Do you know where my favorite place in the entire world is?",
      :fact_item => "I have an entire collection of this author's books... Do you know whose it is?",
      :fact_food => "Guess what my favorite food is!",
      :fact_season => "This is the my favorite season for lattes at Starbucks."
    },
    "Ryan" => {
      :fact_dream => "It's my dream to travel here...",
      :fact_color => "I usually just buy everything in this color... I guess you could say it's my favorite color. Have you noticed what it is?",
      :fact_place => "You can usually find me at...",
      :fact_item => "This means alot to me so I don't want to lose it. Do you remember what it was?",
      :fact_food => "Honestly this is the only thing I can cook because it's my favorite food. Remember what it was?",
      :fact_season => "I love going to the park and reading around this time of year."
    },
    "John" => {
      :fact_dream => "That's a sweet car. It's my dream to buy one of these...",
      :fact_color => "These specific colors look really good on me. I hope you remembered what colors.",
      :fact_place => "Do you remember which gym I like to go to?",
      :fact_item => "Make sure that matches my favorite jacket. You remember which one right?",
      :fact_food => "You should know what my favorite food is by now. What is it?",
      :fact_season => "Men's fashion during this season is the best. You know what I'm talking 'bout?'"
    },
    "Fabio" => {
      :fact_dream => "What do you think I would do when I retire?",
      :fact_color => "I remembered your favorite color. Do you know mine?",
      :fact_place => "I would love to travel here with you... Can you guess where?",
      :fact_item => "There is one thing I cherish more than anything. I hope you know what that is.",
      :fact_food => "Do you know if this restaurant has any of my favorite foods? Do they have...",
      :fact_season => "There is one season I love more than others... Which is it?"
    },
    "Oliver" => {
      :fact_dream => "One day I'd love to retire here...",
      :fact_color => "Do you know what my favorite colors are?",
      :fact_place => "Is it obvious what my favorite plae is? Do you know where that is?",
      :fact_item => "I've been really into this project of mine. Do you know what it is??",
      :fact_food => "Let's eat! I prefer this kind of food...",
      :fact_season => "Do you know what my favorite season is?"
    }
  }
end
