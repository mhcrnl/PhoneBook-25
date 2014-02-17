module CM

require "./record"
require "./merge"
require "./save_phone_book"


  class PhoneBook

    attr_reader :selected, :deleted, :phone_book

    def initialize(phone_book = [])
      @phone_book = phone_book
      @selected = nil
      @parameters = %i(first_name last_name nick_name mobile home email birthdate age address note)
      @deleted = []
    end

    def add_contact(first_name:, mobile:, email:, **kwargs)
      if find_duplicate([mobile].flatten, [email].flatten).empty?
        record = {first_name: first_name, mobile: [mobile].flatten, email: [email].flatten}
        new_parameters = check_for_new_parameters kwargs
        new_parameters.length <= 3 ? add_record(record, kwargs, new_parameters) : "Maximum number of costumized parameters is 3"
      else
        "Zapis s takiva parametri  veche s1shtestvuva"
      end
    end

    def show(phone_book = @phone_book) # sorted by name and proper output
      sort_phone_book(phone_book).map { |record| record.headline }.join
    end

    def edit(selected, key, value = nil, flag = :insert, new_value: nil)
      selected ? selected.edit_record(key, value, flag, new_value) : "No selected contact"
    end

    def search(value, key = :first_name)
      list = @phone_book.select { |contact| [:email, :mobile].include?(key) ? contact.record[key].include?(value) : (contact.record[key] == value) }
      if list.empty?
        "There is no record for contact with #{key.to_s}: #{value}"
      elsif list.length == 1
        list.first.show # shows whole info
      else
        show list # shows only headlines
      end
    end

    def show_selected
      @selected ? @selected.show : "No selected contact"
    end

    def sort_phone_book(phone_book)
      phone_book.sort_by { |item| [item.record[:first_name], item.record.fetch(:last_name, "")].join }
    end

    def select(**kwargs)
      contact = @phone_book.select do|contact|
        kwargs.keys.all? do |key|
          if key == :mobile or key == :email
            contact.record[key].include? kwargs[key]
          else
            contact.record[key] == kwargs[key]
          end
        end
      end

      if contact.length == 1
        puts "You selected: #{contact.first.headline.strip}"
        @selected = contact.first
      elsif contact.length == 0
        "There is no record with that parameters"
      else
        "You need to be more specific"
      end
    end

    def find_duplicate(mobile, email)
      @phone_book.select do |contact|
        !(contact.record[:email] & email).empty? or !(contact.record[:mobile] & mobile).empty?
      end
    end

    def delete_record
      if @selected
        @phone_book.delete @selected
        @deleted.insert 0, @selected
        diselect
      else
        "No selected contact"
      end
    end

    def restore(position = 0)
      if @deleted[position] == nil
        position == 0 ? "No deleted records" : "Deleted records are less than #{position + 1}"
      else
        result = add_contact @deleted[position].record
        result == "Contact added succsessfuly" ? @deleted.delete(sort_phone_book(@deleted)[position]) : result
      end
    end

    def diselect
      @selected = nil
    end

    def check_for_new_parameters(user_parameters)
      new_parameters = user_parameters.keys.select { |parameters| !@parameters.include? parameters }
    end

    def add_record(record, kwargs, new_parameters)
      kwargs.each { |key, value| record[key] = value } # record.merge kwargs this does not work!?!
      parameters = @parameters << new_parameters
      puts new_parameters
      @phone_book << Record.new(record, parameters.flatten)
      "Contact added succsessfuly"
    end

  end
end

a = CM::PhoneBook.new [
        Record.new({first_name: "Georgi", last_name: "Dimitrov", mobile: ["0883463293", "11111111"], email: ["dimitrov@abv.bg", "nenenneen"], age: 23, nick_name: "gogo"},[:first_name, :last_name, :nick_name, :mobile, :home, :email, :birthdate, :age, :address, :note]),
        Record.new({first_name: "Atanas", last_name: "Ivanov", mobile: ["0893325400"], email: ["atanas@abv.bg"], age: 33},[:first_name, :last_name, :nick_name, :mobile, :home, :email, :birthdate, :age, :address, :note]),
        Record.new({first_name: "Georgi", last_name: "Dimitrov", mobile: ["0883425401"], email: ["gosho@abv.bg"], age: 13},[:first_name, :last_name, :nick_name, :mobile, :home, :email, :birthdate, :age, :address, :note]),
        Record.new({first_name: "Atanas", last_name: "Stoqnov", mobile: ["0883325400", "0896382263"], email: ["stoqnov@abv.bg"], age: 43},[:first_name, :last_name, :nick_name, :mobile, :home, :email, :birthdate, :age, :address, :note])
        ]
# a.add_contact( mobile: 3456, email: "dad", note: "ahaaaa", last_name: "todor")
a.add_contact(first_name: "pesho", mobile: 3456, email: "dad", note: "ahaaaa", last_name: "todorov", nov: "nov zapis", nov2: 2, nov3: 3)
puts a.show
# puts a.search "0883463293", :mobile
# atanas = a.select(first_name: "Atanas", last_name: "Stoqnov")
# puts a.show_selected
# a.edit atanas, :mobile, "0883325400", :edit, new_value: "123"
a.select(nov2: 2)
puts a.show_selected
# a.delete_record
# puts a.show
# a.delete_record
# a.restore
# puts a.show a.deleted
# puts a.show
b = CM::PhoneBook.new [
        Record.new({first_name: "Gencho", last_name: "Dimitrov", mobile: ["0883493293"], email: ["gencho@abv.bg"], age: 23, nick_name: "gega"},
                   [:first_name, :last_name, :nick_name, :mobile, :home, :email, :birthdate, :age, :address, :note]),
        Record.new({first_name: "Toshko", last_name: "Toshkov", mobile: ["0883463293"], email: ["toshi@abv.bg", "dadadada"], age: 25},
                   [:first_name, :last_name, :nick_name, :mobile, :home, :email, :birthdate, :age, :address, :note])
      ]
# c = Merger.new.merge a, b
# puts a.show
# puts b.show
# puts c.show
my_book = Save.save_phone_book a, "phone_book"
a = 2
a = Save.load_phone_book my_book
puts a.show
a.select first_name: "pesho"
puts a.show_selected
a.phone_book.first.parameters
