# Load Settler manually to ensure all settings are directly available. 
SETTLER_LOADED = !(Settler.load! rescue nil).nil?
