module ContactMenager

require "./phone_book"
require "./record"
require "./save_phone_book"
require "./merge_controler"
require "./console_controler"

end

# a = Save.load_phone_book "first_test_phone_book"
# a = ContactMenager::PhoneBook.new [
#         Record.new({first_name: "Georgi", last_name: "Ivanov", mobile: ["0883463293", "0879123456"], email: ["ivanov@abv.bg", "gonzo@gmail.com"], age: 23, nick_name: "gonzo", home: "024532190", address: "Georgi Benkovski 25"},[:first_name, :last_name, :nick_name, :mobile, :home, :email, :birthdate, :age, :address, :note]),
#         Record.new({first_name: "Atanas", last_name: "Petkov", mobile: ["0893325400"], email: ["petkov@abv.bg"], age: 33, home: "024222390", address: "Todor Burmov 15", birthdate: "22.02.1981"},[:first_name, :last_name, :nick_name, :mobile, :home, :email, :birthdate, :age, :address, :note]),
#         Record.new({first_name: "Georgi", last_name: "Ivanov", mobile: ["0883425401"], email: ["gosho@abv.bg"], age: 13, address: "Mladost 4 blok: 123", birthdate: "21.12.2001"},[:first_name, :last_name, :nick_name, :mobile, :home, :email, :birthdate, :age, :address, :note]),
#         Record.new({first_name: "Atanas", last_name: "Stoqnov", mobile: ["0883325400", "0896382263"], email: ["stoqnov@abv.bg"], age: 43, note: "Old friend from school"},[:first_name, :last_name, :nick_name, :mobile, :home, :email, :birthdate, :age, :address, :note])
#         ]
# atanas = a.select(first_name: "Atanas", last_name: "Stoqnov")
# puts a.show_selected
# puts a.show
# b = Save.load_phone_book "second_test_phone_book"
# b = ContactMenager::PhoneBook.new [
#         Record.new({first_name: "Gencho", last_name: "Dimitrov", mobile: ["0883493293"], email: ["gencho@abv.bg"], age: 23, nick_name: "gega"},
#                    [:first_name, :last_name, :nick_name, :mobile, :home, :email, :birthdate, :age, :address, :note]),
#         Record.new({first_name: "Toshko", last_name: "Toshkov", mobile: ["0883463293"], email: ["toshi@abv.bg", "toshko@gmail.com"], age: 25},
#                    [:first_name, :last_name, :nick_name, :mobile, :home, :email, :birthdate, :age, :address, :note])
#       ]
# c = MergeControler.new(console: true).merge a, b
