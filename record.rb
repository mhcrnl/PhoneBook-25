class Record

  attr_reader :record, :parameters

  def initialize(record, parameters)
    @record = record
    @parameters = parameters
  end

  def edit_record(key, value, flag, new_value)
    if [:email, :mobile].include? key
      flag_hendler(key, value, flag, new_value)
    elsif value == nil and key == :first_name
      "#{key.to_s} is required field"
    else
      if !@parameters.include? key and @parameters.length < 13
        @record[key] = value
        @parameters << key
      elsif @parameters.include? key
        value != nil ? @record[key] = value : @record.delete(key)
      else
        "You can't customize more than 3 new parameters per contact"
      end
    end
  end

  def show
    @parameters.map do |item|
      if item == :mobile or item == :email
        "#{item.to_s}: #{@record[item].join ", "} \n"
      else
        "#{item.to_s}: #{@record[item]} \n"
      end
    end.join
  end

  def headline
    "#{@record[:first_name]} #{@record.fetch :last_name, ""}#{nick_names}#{@record[:mobile].first} #{@record[:email].first}\n"
  end

  def nick_names
    @record[:nick_name] ? " (#{@record[:nick_name]}) " : " "
  end

  def flag_hendler(key, value, flag, new_value)
    case flag
      when :insert
        @record[key] = (@record[key] << value).uniq.flatten
      when :delete
        @record[key].length > 1 ?  "#{@record[key].delete(value)} deleted" : "#{key.to_s} is required field"
      when :replace
        if @record[key].include? value and !@record[key].include? new_value
          @record[key].insert(@record[key].index(value), new_value).delete value
          @record[key] = @record[key].flatten
          "Value replaced successfully"
        elsif @record[key].include? new_value
          "Value #{new_value} is in the record"
        else
          "The value #{value} is not in the record: #{headline.strip}"
        end
      else
        "There is no such flag #{flag.to_s}"
    end
  end
end