module Sprinkle
  module Installers
    # = RPM Package Installer
    #
    # The RPM package installer installs RPM packages.
    # 
    # == Example Usage
    #
    # Installing the magic_beans RPM. Its all the craze these days.
    #
    #   package :magic_beans do
    #     rpm 'magic_beans'
    #   end
    #
    # You may also specify multiple rpms as an array:
    #
    #   package :magic_beans do
    #     rpm %w(magic_beans magic_sauce)
    #   end
    class Rpm < PackageInstaller

      protected

        def install_commands #:nodoc:
          "rpm -Uvh #{@packages.join(' ')}"
        end

    end
  end
end
