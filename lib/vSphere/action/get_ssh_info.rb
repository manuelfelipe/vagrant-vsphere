require 'rbvmomi'
require 'vSphere/util/vim_helpers'

module VagrantPlugins
  module VSphere
    module Action
      class GetSshInfo
        include Util::VimHelpers


        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:machine_ssh_info] = get_ssh_info(env[:vSphere_connection], env[:machine])

          @app.call env
        end

        private

        def get_defined_private_network(machine)
          private_networks = machine.config.vm.networks.find_all { |n| n[0].eql? :private_network }
          if private_networks.length > 0 then
            #return the first IP listed in config
            return private_networks[0][1][:ip]
          end
          return nil
        end

        def get_ssh_info(connection, machine)
          return nil if machine.id.nil?

          defined = get_defined_private_network(machine)

          return {
              :host => defined,
              :port => 22
          } if defined

          vm = get_vm_by_uuid connection, machine

          return nil if vm.nil?

          return {
              :host => vm.guest.ipAddress,
              :port => 22
          }
        end
      end
    end
  end
end