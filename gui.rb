module GUI

  require "./main"
  require "green_shoes"

  class Gui
    def initialize(app)
      @app = app
      @menagers = {}
      @current_phone_book
      @MAX_CUSTOM_PARAMETER = 3
      navigation_bar
    end

    def navigation_bar
      @nav = @app.stack margin: 4 do
        @app.flow do
          @app.button "Create" do
            if @e.text == ""
              @app.alert "Enter name for phone book please"
            elsif @menagers[@e.text] != nil
              @app.alert "Phone book #{@e.text} is already loaded"
            else
              @name = @e.text
              @menagers[@e.text] = PhoneBook.new
              @current_phone_book = @menagers[@name]
                @app.append do
                  @contact_list = @app.stack do
                  add_book(@current_phone_book, @name)
                  end
                end
              @e.text = ""
            end
          end

          @e = @app.edit_line :width => 450, :height => 25

          @app.button "Load" do

            if @e.text == ""
              @app.alert "Enter name for phone book please"
            elsif @menagers[@e.text] != nil
              @app.alert "Phone book #{@e.text} is already loaded"
            else
              @name = @e.text
              @menagers[@e.text] = Save.load_phone_book @e.text
              if @menagers[@name].is_a? String
                @app.alert @menagers[@name]
                @menagers.delete @name
                @name = nil
              else
                @current_phone_book = @menagers[@name]
                @app.append do
                  @contact_list = @app.stack do
                  add_book(@current_phone_book, @name)
                  end
                end
                @e.text = ""
              end
            end

          end
        end
      # end
        @app.flow do
        # @nav.append do
          @app.para "Merge", width: 50, align: 'center'
          merge_to = @app.edit_line :height => 25
          @app.para "with", width: 40, align: 'center'
          merge_with = @app.edit_line :height => 25
          @app.button "Merge" do
            if @menagers[merge_to.text] == nil or @menagers[merge_with.text] == nil
              @app.alert "You must load phone books"
            else
              merge_phone_book(
                               @menagers[merge_to.text],
                               @menagers[merge_with.text],
                               merge_to.text, merge_with.text
                               )
            end
          end
        # end
        end
      end
    end

    def add_book(phone_book, name)
      contact_list = @app.stack
      @adding_button = @app.button "Add new record" do
        contact_list.prepend do
          @adding_field = @app.stack margin: 4
          @adding_field.append do
            add_new_record phone_book, contact_list, name
          end
        end
      end

      @app.para "Phone book #{name}:"
      phone_book.phone_book.each do |contact|
        contact_list.append do
          @app.button contact.headline, :width => 400, :height => 30, margin: 4 do

            open_new_app(phone_book, contact)
          end
        end
      end

      contact_list.append do
        @app.flow do

          @app.button "Save phone book" do
            Save.save_phone_book phone_book, name
          end

          @app.button "Update" do
            contact_list.clear do add_book(phone_book, name) end
          end

          @app.button "Clear All" do
            @app.clear do
              navigation_bar
              @menagers = {}
              @current_phone_book = nil
              @name = nil
            end
          end

        end
      end

    end

    def add_new_record(phone_book, contact_list, name)
      @new_contact_records = {}

      phone_book.parameters.each do |parameter|
        @app.flow do
          @app.para parameter.to_s, width: 80
          value = @app.edit_line do
            @new_contact_records[parameter] = value.text == "" ? nil : value.text
          end
        end
      end

      @MAX_CUSTOM_PARAMETER.times do
        @app.flow do
          @app.para "Custom record:", width: 110, align: 'right'
          param_value = ""
          old_param_value = ""
          param = @app.edit_line do
            old_param_value = param_value
            param_value = param.text
            @new_contact_records.delete(old_param_value.to_sym) if @new_contact_records[old_param_value.to_sym]
          end
          value = @app.edit_line do
            unless param_value == "" or value.text == ""
              @new_contact_records[param_value.to_sym] = value.text == "" ? nil : value.text
            end
          end
        end

      end
      @app.flow do
        @app.button "Preview" do
          @app.alert @new_contact_records.inspect
        end
        @app.button "Add to phone book" do
          required = [@new_contact_records[:first_name], @new_contact_records[:mobile], @new_contact_records[:email]]
          if !required.all?
            @app.alert "first_name, mobile and email are required fields"
          else
            message = phone_book.add_contact @new_contact_records
            if message == "Contact added succsessfuly"
              @app.alert message
              contact_list.clear do add_book(phone_book, name) end
            else
              @app.alert message
            end
          end
        end
      end
    end

    def merge_phone_book(first, second, first_name, second_name)
      merger = MergeControler.new gui: true
      merged = merger.merge(first, second)
      @menagers[first_name] = merged
      p merged
      @app.clear do
        @menagers = {}
        @menagers[first_name] = merged
        @current_phone_book = merged
        @name = first_name
        navigation_bar
        @nav.append do
          @contact_list = @app.stack do
            add_book(@current_phone_book, @name)
          end
        end
      end
    end

    def open_new_app(phone_book, contact)
      new_app = Shoes.app do
        Editer.new self, phone_book, contact
      end
    end

  end

  class Editer
    def initialize(app, phone_book, contact)
        @app = app
        @phone_book = phone_book
        @contact = contact
        @MAX_PARAMETERS = 13
        load_info
    end

    def load_info
      @phone_book.select mobile: @contact.record[:mobile].first
      @selected = @phone_book.selected

      @info = @app.stack margin: 4
      @info.append do
        load_records
      end
    end

    def load_records
      @contact.parameters.each do |parameter|
        param_record = @app.flow do
        # @info.append do
          # param_record.append do
          if [:email, :mobile].include? parameter
            @app.para parameter, width: 80, align: 'right'
            @selected.record[parameter].each do |record_value|
              value = @app.edit_line record_value
              old_value = value.text
              option = :insert
              option_chooser = @app.list_box(
                            items: ["insert", "delete", "replace"],
                            width: 60,
                            choose: "insert"
                            ) do |list|
                option = list.text.to_sym
              end
              @app.button "Edit" do
                if option == :replace
                  message = @phone_book.edit parameter, old_value, option, new_value: value.text
                  @info.clear do load_records end
                else
                  message = @phone_book.edit parameter, value.text, option
                  @info.clear do load_records end
                end
                if message.is_a? String
                  @app.alert message
                end
              end

            end
          else
            @app.para parameter, width: 80, align: 'right'
            value = @app.edit_line "#{@selected.record[parameter].to_s}"
            old_value = value.text
            @app.button "Edit" do
              message = @phone_book.edit(parameter, value.text == "" ? nil : value.text)
              if message != value.text and parameter == :first_name
                @app.alert message
                value.text = old_value
              end
            end
          end
        end
        # end
      end #contact.parameters.each

      (@MAX_PARAMETERS - @selected.parameters.length).times do
        custom = @app.flow
        @info.append do
          custom.append do
            param = @app.edit_line "new_param"
            value = @app.edit_line "set_value"
            @app.button "Edit" do
              message = @phone_book.edit(param.text.to_sym, value.text == "" ? nil : value.text)
              if message.is_a? String
                @app.alert message
                value.text = "set_value"
                param.text = "new_param"
              end
              @info.clear do load_records end
            end
          end
        end
      end
      @info.append do
        @app.flow do

          @app.button "Close" do
            @contact_list.clear
            @app.close
          end

          @app.button "Delete" do
            @phone_book.delete_record
            @contact_list.clear
            @app.close
          end

        end
      end
    end
  end
end

Shoes.app do
  GUI::Gui.new self
end