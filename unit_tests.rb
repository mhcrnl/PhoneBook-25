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

  it "Add new contact with customized parameter" do
    first_test_book.add_contact(
                                first_name: "Pesho",
                                mobile: "0897998877",
                                email: "todorov@gmail.com",
                                customized: "This is something uniq for me"
                                ).should eq "Contact added succsessfuly"

    first_test_book.phone_book.last.record[:customized].should eq "This is something uniq for me"
    first_test_book.phone_book.last.parameters.should include :customized
  end

  it "Doesn't add new contact with more than 3 customized parameters" do
    first_test_book.add_contact(
                                first_name: "Pesho",
                                mobile: "0897998877",
                                email: "todorov@gmail.com",
                                customized: "This is something uniq for me",
                                customized_again: 2,
                                fax: "02342553",
                                too_much: "Can't handle it"
                                ).should eq "Maximum number of customized parameters is 3"

    first_test_book.phone_book.last.parameters.should_not include :fax
  end

  it "Doesn't add new contact with required records that already exists" do
    length = first_test_book.phone_book.length
    first_test_book.add_contact(
                                first_name: "Pesho",
                                mobile: "0883463293",
                                email: "todorov@gmail.com"
                                ).should eq "Record with such parameters already exists"

    first_test_book.phone_book.length.should eq length
  end

  it "Edit unspecial record" do
    first_test_book.select first_name: "Atanas", last_name: "Stoqnov"
    first_test_book.edit :last_name, "Krasimirov"
    first_test_book.diselect

    first_test_book.selected.should eq nil

    first_test_book.select(last_name: "Krasimirov")
    first_test_book.selected.record[:last_name].should eq "Krasimirov"
    first_test_book.selected.record[:note].should eq "Old friend from school"
  end

  it "Doesn't remove first name" do
    first_test_book.select first_name: "Atanas", last_name: "Stoqnov"
    first_test_book.edit(:first_name, nil).should eq "first_name is required field"
    first_test_book.selected.record[:first_name].should eq "Atanas"
  end

  it "Remove last name" do
    first_test_book.select first_name: "Atanas", last_name: "Stoqnov"
    first_test_book.edit :last_name, nil
    first_test_book.selected.record[:last_name].should eq nil
  end

  it "Add custom parameter" do
    first_test_book.select first_name: "Atanas", last_name: "Stoqnov"
    first_test_book.edit :customized, "This is something uniq for me"
    first_test_book.selected.record[:customized].should eq "This is something uniq for me"
    first_test_book.phone_book.last.parameters.should include :customized
  end

  it "Doesn't add more than 3 custom parameters" do
    first_test_book.select first_name: "Atanas", last_name: "Stoqnov"
    first_test_book.edit :customized, "This is something uniq for me"
    first_test_book.edit :customized_again, 2
    first_test_book.edit :fax, "02342553"
    first_test_book.edit(
                         :too_much,
                         "Can't handle it"
                         ).should eq "You can't customize more than 3 new parameters per contact"

    first_test_book.selected.record[:too_much].should eq nil
    first_test_book.phone_book.last.parameters.should_not include :too_much
  end

  it "Edit required field - insert one mobile number" do
    first_test_book.select first_name: "Atanas", last_name: "Stoqnov"
    first_test_book.edit :mobile, "0883112233"
    first_test_book.selected.record[:mobile].should =~ [
                                                        "0883325400",
                                                        "0896382263",
                                                        "0883112233"
                                                        ]
  end

  it "Edit required field - insert two mobile numbers" do
    first_test_book.select first_name: "Atanas", last_name: "Stoqnov"
    first_test_book.edit :mobile, ["0883112233", "0883445566"]
    first_test_book.selected.record[:mobile].should =~ [
                                                        "0883445566",
                                                        "0883325400",
                                                        "0896382263",
                                                        "0883112233"
                                                       ]
  end

  it "Edit required field - insert duplicate mobile number" do
    first_test_book.select first_name: "Atanas", last_name: "Stoqnov"
    first_test_book.edit :mobile, "0883325400"
    first_test_book.selected.record[:mobile].should =~ [
                                                        "0883325400",
                                                        "0896382263",
                                                        ]
  end

  it "Edit required field - insert mobile number that duplicates in other contact" do
    first_test_book.select first_name: "Atanas", last_name: "Stoqnov"
    first_test_book.edit(:mobile, "0883425401").should eq "Value duplicates in other contact"
    first_test_book.selected.record[:mobile].should =~ [
                                                        "0883325400",
                                                        "0896382263",
                                                        ]
  end

  it "Edit required field - replace mobile number" do
    first_test_book.select first_name: "Atanas", last_name: "Stoqnov"
    first_test_book.edit :mobile, "0883325400", :replace, new_value: "0897111111"
    first_test_book.selected.record[:mobile].should == [
                                                        "0897111111",
                                                        "0896382263",
                                                        ]
  end

  it "Edit required field - replace mobile number with two" do
    first_test_book.select first_name: "Atanas", last_name: "Stoqnov"
    first_test_book.edit(
                         :mobile,
                         "0883325400",
                         :replace,
                         new_value: ["0897111111", "0899009988"]
                         ).should eq "Value replaced successfully"

    first_test_book.selected.record[:mobile].should =~ [
                                                        "0897111111",
                                                        "0896382263",
                                                        "0899009988"
                                                        ]
  end

  it "Edit required field - replace mobile number with one that duplicates in other contact" do
    first_test_book.select first_name: "Atanas", last_name: "Stoqnov"
    first_test_book.edit(
                         :mobile,
                         "0883325400",
                         :replace,
                         new_value: "0883425401"
                         ).should eq "Value duplicates in other contact"

    first_test_book.selected.record[:mobile].should == [
                                                        "0883325400",
                                                        "0896382263",
                                                        ]
  end

  it "Edit required field - replace unexisting mobile number" do
    first_test_book.select first_name: "Atanas", last_name: "Stoqnov"
    first_test_book.edit(
                         :mobile,
                         "0883111111",
                         :replace, new_value: "0897222222"
                         ).should eq "The value 0883111111 is not in the record: #{first_test_book.selected.headline.strip}"
    first_test_book.selected.record[:mobile].should == [
                                                        "0883325400",
                                                        "0896382263",
                                                        ]
  end

  it "Edit required field - delete mobile number" do
    first_test_book.select first_name: "Atanas", last_name: "Stoqnov"
    first_test_book.edit :mobile, "0883325400", :delete
    first_test_book.selected.record[:mobile].should == ["0896382263"]
  end

  it "Edit required field - doesn't delete the only mobile number" do
    first_test_book.select first_name: "Atanas", last_name: "Stoqnov"
    first_test_book.edit :mobile, "0883325400", :delete
    first_test_book.edit(:mobile, "0896382263", :delete).should eq "mobile is required field"
    first_test_book.selected.record[:mobile].should == ["0896382263"]
  end

  it "Edit required field - wrong flag" do
    first_test_book.select first_name: "Atanas", last_name: "Stoqnov"
    first_test_book.edit(:mobile, "0896382263", :wrong_flag).should eq "There is no such flag wrong_flag"
    first_test_book.selected.record[:mobile].should == ["0883325400", "0896382263"]
  end

  it "Select record" do
    first_test_book.select nick_name: "gonzo"
    first_test_book.selected.record[:first_name].should eq "Georgi"
    first_test_book.selected.record[:last_name].should eq "Ivanov"
  end

  it "Doesn't select multiple records" do
    first_test_book.select(first_name: "Georgi").should eq "You need to be more specific"
    first_test_book.selected.should eq nil
  end

  it "Does't select nonexistent record" do
    first_test_book.select(nonexistent: "Georgi").should eq "There is no record with that parameters"
    first_test_book.selected.should eq nil
  end

  it "Delete record" do
    first_test_book.select nick_name: "gonzo"
    first_test_book.delete_record
    first_test_book.selected.should eq nil
    first_test_book.select(nick_name: "gonzo").should eq "There is no record with that parameters"
  end

  it "Restore deleted record" do
    first_test_book.select nick_name: "gonzo"
    first_test_book.delete_record
    first_test_book.selected.should eq nil
    first_test_book.select(nick_name: "gonzo").should eq "There is no record with that parameters"
    first_test_book.restore
    first_test_book.deleted.should eq []
    first_test_book.select nick_name: "gonzo"
    first_test_book.selected.record[:nick_name].should eq "gonzo"
  end

  it "Doesn't delete unselected record" do
    first_test_book.delete_record.should eq "No selected contact"
  end
end