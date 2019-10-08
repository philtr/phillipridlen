# Rules
#
# Try to keep the number of rules defined in this file to a minumum.
#
# - Preprocess methods go in `lib/preprocessors`
# - Rule sets go in `lib/rules`
# - Everything else can go here
#
preprocess do
  preprocess_blog
end

layout "/**/*", :erb

# Rules for Specific Items
include_rules "rules/home"
include_rules "rules/errors"
include_rules "rules/resources"

# Rules for Special Groups of Items
include_rules "rules/blog"

# Rules for Processing Stylesheets
include_rules "rules/stylesheets"

# Rules for Specific File Extensions
include_rules "rules/haml"
include_rules "rules/markdown"

# Catch-All for Everything Else
passthrough "/**/*"

