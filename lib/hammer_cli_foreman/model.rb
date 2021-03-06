module HammerCLIForeman

  class Model < HammerCLI::Apipie::Command

    resource ForemanApi::Resources::Model

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, "Id"
        field :name, "Name"
        field :vendor_class, "Vendor class"
        field :hardware_model, "HW model"
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      output ListCommand.output_definition do
        field :info, "Info"
        field :created_at, "Created at", Fields::Date
        field :updated_at, "Updated at", Fields::Date
      end

      apipie_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand
      success_message "Hardware model created"
      failure_message "Could not create the hardware model"

      apipie_options
    end

    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message "Hardware model deleted"
      failure_message "Could not delete the hardware model"

      apipie_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      success_message "Hardware model updated"
      failure_message "Could not update the hardware model"

      apipie_options
    end


    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'model', "Manipulate hardware models.", HammerCLIForeman::Model

