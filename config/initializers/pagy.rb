# Pagy initializer
require 'pagy/extras/overflow'

Pagy::DEFAULT[:items] = 24  # Produits par page
Pagy::DEFAULT[:overflow] = :last_page  # Si page > max, redirect dernière page
