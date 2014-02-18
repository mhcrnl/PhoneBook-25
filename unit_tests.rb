describe ContactMenager do
  let(:first_test_book) { Save.load_phone_book File.join(File.dirname(__FILE__), "first_test_phone_book") }

  let(:second_test_book) { Save.load_phone_book File.join(File.dirname(__FILE__), "second_test_phone_book") }

  it "Add new contact" do
    first_test_book.add_contact(
                                first_name: "Pesho",
                                mobile: "0897998877",
                                email: "todorov@gmail.com",
                                note: "Test adding contact",
                                last_name: "Todorov"
                                ).should eq "Contact added succsessfuly"

    first_test_book.phone_book.last.record[:note].should eq "Test adding contact"
  end

end