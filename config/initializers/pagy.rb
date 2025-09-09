# Pagy Configuration

require 'pagy/extras/overflow'

# Default items per page  
Pagy::DEFAULT[:limit] = 2

# Enable overflow handling - when page is out of range
Pagy::DEFAULT[:overflow] = :last_page