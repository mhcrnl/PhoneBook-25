class Save

  require "json"
  # attr_reader

  def initialize(object, file_name)
    @object = object
    # @option = option
    @file_name = file_name
  end

  def save
    objects = @object.map do |contact|
      record = contact.record
      record[:parameters] = contact.parameters
      record
    end

    File.open("./#{@file_name}.json","w") do |f|
      f.write(JSON.pretty_generate(objects))
    end
  end

  def load_phone_book
    loaded = JSON.parse(IO.read "./#{@file_name}.json").map do |json_hash|
      new_hash = {}
      json_hash.each { |key, value| new_hash[key.to_sym] = value }
      parameters = new_hash[:parameters]
      new_hash[:parameters] = nil
      Record.new new_hash, parameters
    end
    CM::PhoneBook.new loaded
  end
end