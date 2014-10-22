# Switchable JSON dumpers. If Oj gem is installed then we'll use that,
# otherwise we'll fall back to to_json. This is because to_json may have issues
# with encoding, but I don't want to force people to install a C-language
# gem, along with a compiler and ruby development libraries etc.

require 'json'

def dump_json(structure)
  begin
    require 'Oj'
    Oj.dump(structure, mode: :compat)
  rescue LoadError
    structure.to_json
  end
end
