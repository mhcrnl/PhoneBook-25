class PhoneBook

  attr_reader :selected, :deleted, :phone_book, :parameters

  def initialize(phone_book = [])
    @phone_book = phone_book
    @required = %i(mobile email)
    @selected = nil
    @parameters = %i(first_name last_name nick_name mobile home email birthdate age address note)
    @deleted = []
    @MAX_CUSTOM_PARAMETER = 3
  end

  def add_contact(first_name:, mobile:, email:, **kwargs)
    if find_duplicate([mobile].flatten, [email].flatten).empty?
      record = {first_name: first_name, mobile: [mobile].flatten, email: [email].flatten}
      new_parameters = check_for_new_parameters kwargs

      if new_parameters.length <= @MAX_CUSTOM_PARAMETER
        add_record(record, kwargs, new_parameters)
      else
        "Maximum number of customized parameters is #{@MAX_CUSTOM_PARAMETER}"
      end

    else
      "Record with such parameters already exists"
    end
  end

  def show(phone_book = @phone_book) # sorted by name and proper output
    sort_phone_book(phone_book).map { |record| record.headline }.join
  end

  def edit(key, value = nil, flag = :insert, new_value: nil)
    if new_value ? duplicate?([new_value]) : duplicate?([value])
      "Value duplicates in other contact"
    else
      @selected ? @selected.edit_record(key, value, flag, new_value) : "No selected contact"
    end
  end

  def search(value, key = :first_name)
    list = @phone_book.select { |contact| @required.include?(key) ? contact.record[key].include?(value) : (contact.record[key] == value) }
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
        if @required.include? key
          contact.record[key].include? kwargs[key]
        else
          contact.record[key] == kwargs[key]
        end
      end
    end

    if contact.length == 1
      @selected = contact.first
      "You selected: #{contact.first.headline.strip}"
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

  private

  def duplicate?(value)
    contact_and_emails = (@phone_book - [@selected]).map { |contact| [contact.record[:email], contact.record[:mobile]] }
    !(contact_and_emails.flatten & value.flatten).empty?
  end

  def check_for_new_parameters(user_parameters)
    new_parameters = user_parameters.keys.select { |parameters| !@parameters.include? parameters }
  end

  def add_record(record, kwargs, new_parameters)
    kwargs.each { |key, value| record[key] = value } # record.merge kwargs this does not work!?!
    if new_parameters.empty?
      parameters = @parameters
    else
      parameters = @parameters.map { |parameter| parameter}
      parameters << new_parameters
    end
    @phone_book << Record.new(record, parameters.flatten)
    "Contact added succsessfuly"
  end

end