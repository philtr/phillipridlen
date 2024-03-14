module PhillipRidlen
  module DataSources
    module FilesystemListener
      def layout_changes = watch_for_changes(:layouts)
      def item_changes = watch_for_changes(:content)

      private def watch_for_changes(kind)
        if (dir = dir_for(kind))
          start(dir)
        else
          # Nothing to watch for changes
          Enumerator.new { sleep }
        end
      end

      private def dir_for(kind)
        @config.fetch(:"#{kind}_dir", nil)
      end

      private def start(dir)
        require "listen"

        Nanoc::Core::ChangesStream.new do |cl|
          full_dir = File.expand_path(dir)

          listener = Listen.to(full_dir) { cl.unknown }
          listener.start

          cl.to_stop { listener.stop }

          sleep
        end
      end
    end
  end
end
