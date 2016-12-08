require 'u3d_core'
require 'u3d'

#require 'coveralls'

module SpecHelper
end

# Executes the provided block after adjusting the ENV to have the
# provided keys and values set as defined in hash. After the block
# completes, restores the ENV to its previous state.
def with_env_values(hash)
  old_vals = ENV.select { |k, v| hash.include?(k) }
  hash.each do |k, v|
    ENV[k] = hash[k]
  end
  yield
ensure
  hash.each do |k, v|
    ENV.delete(k) unless old_vals.include?(k)
    ENV[k] = old_vals[k]
  end
end