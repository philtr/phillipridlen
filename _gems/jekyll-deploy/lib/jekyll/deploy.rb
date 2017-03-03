class Deploy < Jekyll::Command
  class << self
    def init_with_program(prog)
      prog.command(:deploy) do |c|
        c.syntax "deploy"
        c.description 'Deploy site using s3_website'

        c.option "tidy",      "--tidy",     "Use tidy-html5 to format outputted site"
        c.option "[no-]tag"   "--[no-]tag"  "Tag this deploy in Git with an incremental build number"

        c.action do |args, options|
          Jekyll::Commands::Build.process({})

          if options["tidy"]
            if `tidy --version` =~ /version 5\./
              puts "Tidying HTML..."
              system("find _site/ -name '*.html' -exec tidy -config _config/tidy.conf {} \\;")
            end
          end

          unless options["no-tag"]
            build = `git tag`
              .split("\n")
              .select { |tag| tag =~ /\Ab\d+$\Z/ }
              .map { |tag| tag[1..-1].to_i }
              .sort
              .last
              .next

            system("git tag b#{build.to_s.rjust(4, "0")}")
          end

          system("bundle exec s3_website push", out: $stdout)
        end
      end
    end
  end
end
