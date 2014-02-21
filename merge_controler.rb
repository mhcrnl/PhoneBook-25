class MergeControler
  def initialize(console: false, gui: false)
    @options = %i(first second merge)
    @console = console
    @required = %i(mobile email)
    @gui = gui
  end

  def merge(first, second)
    @merged = PhoneBook.new
    first.phone_book.each { |contact| @merged.add_contact contact.record }

    second.phone_book.each do |contact|
      duplicate = @merged.find_duplicate(contact.record[:mobile], contact.record[:email])
      if duplicate.empty?
        @merged.add_contact contact.record
      else
        if @console
          console_hendler(duplicate.first, contact)
        elsif @gui
          gui_hendler(duplicate.first, contact)
        else
          return "Choose controler"
        end
      end
    end

    @merged
  end

  def console_hendler(duplicate, contact)
    user_option = user_option_input(duplicate, contact)
    if user_option == :merge
      user_changes = user_changes_input(duplicate, contact)
      extract_records(duplicate, contact, user_changes)
    else
      puts collision_handler(duplicate, contact, user_option)
    end
  end

  def gui_hendler(duplicate, contact)
    user_option = nil
    options = @options
    Shoes.app do
      message = "#{duplicate.headline.strip}\nduplicates with #{contact.headline}"
      question = "Select one of this options: #{options.join(", ").to_s}"
      option = ask("#{message}\n#{question}")
      user_option = option == nil ? :first : option.to_sym
      until options.include? user_option
        alert "Avelabal options are #{options.join(", ").to_s}"
        option = ask("#{message}\n#{question}")
        user_option = option == nil ? :first : option.to_sym
      end
      # close
    end
      p user_option
    if user_option == :merge
      user_changes = nil
      Shoes.app do
        message = "Choose which record from:\n#{contact.show}\nto replace in\n#{duplicate.show}"
        changes = ask(message)
        user_changes = changes == nil ? [] : changes.split(" ").map { |record| record.to_sym }
        until (user_changes - contact.parameters).size == 0 and !user_changes.empty?
          alert "Some parameters are incorrect: #{user_changes.join(", ").to_s}"
          changes = ask(message)
          user_changes = changes == nil ? [] : changes.split(" ").map { |record| record.to_sym }
        end
      # close
      end
      extract_records(duplicate, contact, user_changes)
    else
      collision_handler(duplicate, contact, user_option)
    end
  end

  def user_option_input(duplicate, new_contact)
    puts "#{duplicate.headline.strip} duplicates with #{new_contact.headline}"
    puts "Select one of this options: #{@options.join(", ").to_s}\n"

    option = gets.chomp.to_sym
    until @options.include? option
       puts "Avelabal options are #{@options.join(", ").to_s}"
       option = gets.chomp.to_sym
    end

    option
  end

  def collision_handler(duplicate, new_contact, option)
    case option
      when :first
        return "Did't add\n#{new_contact.headline}"
      when :second
        @merged.phone_book.delete duplicate
        @merged.add_contact new_contact.record
        return "Repleced #{duplicate.headline.strip} with #{new_contact.headline}"
    end
  end

  def user_changes_input(duplicate, new_contact)
    puts "Choose which record from:\n"
    puts "#{new_contact.show}\nto replace in\n"
    puts "#{duplicate.show}"

    changes = gets.strip.split(" ").map { |record| record.to_sym }
    until (changes - new_contact.parameters).size == 0
      puts "Some parameters are incorrect: #{changes.join(", ").to_s}"
      changes = gets.strip.split(" ").map { |record| record.to_sym }
    end

    changes
  end

  def extract_records(duplicate, new_contact, changes)
    @merged.phone_book.delete duplicate
    join_record = required_record_joiner(duplicate, new_contact, changes)

    changes.each { |key| join_record[key] = new_contact.record[key] }
    (duplicate.record.keys - changes - @required).each { |key| join_record[key] = duplicate.record[key] }

    @merged.add_contact join_record
    return "The new record is:\n#{@merged.phone_book.last.show}"
  end

  def required_record_joiner(duplicate, new_contact, changes)
    if changes.include? :email or changes.include? :mobile
      if changes.include? :email and changes.include? :mobile
        {
          email: new_contact.record[:email],
          mobile: new_contact.record[:mobile]
        }
      else
        choosen = (changes & [:email]).empty? ? :mobile : :email
        unchoosen = (@required - [choosen]).first
        {
          unchoosen => (duplicate.record[unchoosen] + new_contact.record[unchoosen]).uniq,
          choosen => new_contact.record[choosen]
        }
      end
    else
      {
        email:  (duplicate.record[:email] + new_contact.record[:email]).uniq,
        mobile: (duplicate.record[:mobile] + new_contact.record[:mobile]).uniq
      }
    end
  end
end