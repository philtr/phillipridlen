class Deploy < Jekyll::Command
  class << self
    def init_with_program(prog)
      prog.command(:deploy) do |c|
        c.syntax "deploy"
        c.description 'Deploy site using s3_website'

        c.option "tidy", "--tidy", "Use tidy-html5 to format outputted site"

        c.action do |args, options|
          Jekyll::Commands::Build.process({})

          if options["tidy"]
            if `tidy --version` =~ /version 5\./
              puts "Tidying HTML..."
              system("find _site/ -name '*.html' -exec tidy -config _config/tidy.conf {} \\;")
            end
          end

          system("bundle exec s3_website push", out: $stdout)
        end
      end
    end
  end
end
