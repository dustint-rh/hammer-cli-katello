module HammerCLIKatello

  class ContentHostCommand < HammerCLI::AbstractCommand
    module IdDescriptionOverridable
      def self.included(base)
        base.option "--id", "ID",
                    _("ID of the content host")
      end
    end

    class ListCommand < HammerCLIKatello::ListCommand
      resource :systems, :index

      def param_to_resource(param_name)
        if param_name == 'environment_id'
          HammerCLIForeman.param_to_resource('lifecycle_environment_id')
        else
          super
        end
      end

      def get_scoped_options(resource)
        if(resource.name.to_s.include? 'environment')
          resolver.scoped_options('environment', all_options)
        else
          resolver.scoped_options(resource.singular_name, all_options)
        end
      end

      output do
        field :uuid, _("ID")
        field :name, _("Name")
      end

      build_options
    end

    class InfoCommand < HammerCLIKatello::InfoCommand
      include IdDescriptionOverridable
      resource :systems, :show

      output do
        field :name, _("Name")
        field :uuid, _("ID")
        field :description, _("Description")
        field :location, _("Location")
        from :environment do
          field :name, _("Lifecycle Environment")
        end
        from :content_view do
          field :name, _("Content View")
        end
        field :entitlementStatus, _("Entitlement Status")
        field :releaseVer, _("Release Version")
        field :autoheal, _("Autoheal")
      end

      build_options
    end

    class CreateCommand < HammerCLIKatello::CreateCommand
      resource :systems, :create

      output InfoCommand.output_definition

      success_message _("Content host created")
      failure_message _("Could not create content host")

      def request_params
        super.tap do |params|
          params['type'] = "system"
          params['facts'] = {"uname.machine" => "unknown"}
        end
      end

      build_options :without => [:facts, :type, :installed_products]
    end

    class UpdateCommand < HammerCLIKatello::UpdateCommand
      include IdDescriptionOverridable
      resource :systems, :update

      success_message _("Content host updated")
      failure_message _("Could not update content host")

      build_options :without => [:facts, :type, :installed_products]
    end

    class DeleteCommand < HammerCLIKatello::DeleteCommand
      include IdDescriptionOverridable
      resource :systems, :destroy

      success_message _("Content host deleted")
      failure_message _("Could not delete content host")

      build_options
    end

    class TasksCommand < HammerCLIKatello::ListCommand
      include IdDescriptionOverridable
      resource :systems, :tasks

      command_name "tasks"

      build_options
    end

    autoload_subcommands
  end

  cmd_name = "content-host"
  cmd_desc = _("manipulate content hosts on the server")
  cmd_cls  = HammerCLIKatello::ContentHostCommand
  HammerCLI::MainCommand.subcommand(cmd_name, cmd_desc, cmd_cls)

end
