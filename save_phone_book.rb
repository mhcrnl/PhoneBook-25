class Save

  require "json"

  def self.save_phone_book(object, file_name)
    objects = object.phone_book.map do |contact|
      record = contact.record
      record[:parameters] = contact.parameters
      record
    end

    File.open("#{file_name}.json","w") do |f|
      f.write(JSON.pretty_generate(objects))
    end

    file_name
  end

  def self.load_phone_book(file_name)
    loaded = JSON.parse(IO.read "#{file_name}.json").map do |json_hash|
      new_hash = {}
      json_hash.each { |key, value| new_hash[key.to_sym] = value }
      parameters = new_hash[:parameters].map { |value| value.to_sym }
      new_hash.delete :parameters
      Record.new new_hash, parameters
    end
    PhoneBook.new loaded
  end
end