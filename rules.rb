# Rules
#
# Try to keep the number of rules defined in this file to a minimum.
#
# - Preprocess methods can go in `lib/preprocessors`
# - Rule sets go in `lib/rules` and have their own preprocess blocks
# - Everything else can go here
layout "/**/*", :erb

# Rules for Specific Items
include_rules "config/rules/home"
include_rules "config/rules/errors"

include_rules "config/rules/resources"
# Rules for Speconfig/cial Groups of Items
include_rules "config/rules/blog"
include_rules "config/rules/photos"

# Rules for Speconfig/cific File Extensions
include_rules "config/rules/erb"
include_rules "config/rules/haml"
include_rules "config/rules/markdown"

# Catch-All for Everything Else
passthrough "/**/*"
