# db/seeds.rb - Fichier seeds professionnel pour la marketplace
# 🌱 SEEDS DONNÉES PROFESSIONNELLES
#
# Ce fichier peuple la base avec des données réalistes pour :
# - Environnement de développement
# - Tests de performance
# - Démo produit
#
# Usage :
#   rails db:seed (première fois)
#   rails db:reset (pour repartir à zéro)

puts "🌱 Début du seeding..."

# ========================================
# 📧 CRÉATION DES UTILISATEURS
# ========================================

puts "👥 Création des utilisateurs..."

# Admin / Demo principal
admin = User.find_or_create_by!(email: "admin@innovaition.cloud") do |user|
  user.password = "password"
  user.password_confirmation = "password"
end

# Vendeurs fictifs réalistes
vendeurs = [
  { email: "marie.dubois@email.com", nom: "Marie Dubois" },
  { email: "thomas.martin@email.com", nom: "Thomas Martin" },
  { email: "sophie.bernard@email.com", nom: "Sophie Bernard" },
  { email: "lucas.petit@email.com", nom: "Lucas Petit" },
  { email: "emma.garcia@email.com", nom: "Emma Garcia" },
  { email: "antoine.roux@email.com", nom: "Antoine Roux" },
  { email: "julie.moreau@email.com", nom: "Julie Moreau" },
  { email: "maxime.laurent@email.com", nom: "Maxime Laurent" }
]

users = vendeurs.map do |vendeur|
  User.find_or_create_by!(email: vendeur[:email]) do |user|
    user.password = "password"
    user.password_confirmation = "password"
  end
end

puts "#{users.count + 1} utilisateurs créés (admin + #{users.count} vendeurs)"

# ========================================
# CRÉATION DES PRODUITS
# ========================================

puts "Création des produits..."

# Catégories et produits réalistes pour une marketplace française
categories_produits = {
  "Électronique" => [
    {
      name: "iPhone 14 Pro - Occasion",
      description: "iPhone 14 Pro de 256 Go en excellent état. Utilisé pendant 6 mois avec protection écran et coque. Batterie à 95%. Livré avec chargeur d'origine et boîte.",
      price: 899.99
    },
    {
      name: "MacBook Air M2 2022",
      description: "MacBook Air 13 pouces avec puce M2, 8 Go de RAM et 256 Go SSD. Parfait état, très peu utilisé. Idéal pour étudiants ou professionnels nomades.",
      price: 1199.00
    },
    {
      name: "Samsung Galaxy S23",
      description: "Samsung Galaxy S23 128 Go noir fantôme. État impeccable, toujours sous garantie jusqu'en mars 2025. Écran sans rayure, fonctionnement parfait.",
      price: 649.50
    },
    {
      name: "Nintendo Switch OLED",
      description: "Console Nintendo Switch modèle OLED avec Joy-Con néon. Très bon état, peu utilisée. Livrée avec dock, câbles et 3 jeux inclus.",
      price: 289.99
    },
    {
      name: "iPad Air 5ème génération",
      description: "iPad Air M1 64 Go Wi-Fi couleur gris sidéral. Excellent état, utilisé principalement pour la lecture. Livré avec Apple Pencil de 2ème génération.",
      price: 449.00
    },
    {
      name: "AirPods Pro 2ème génération",
      description: "AirPods Pro avec réduction de bruit active et boîtier de charge sans fil. Neufs, jamais déballés. Garantie Apple complète.",
      price: 249.00
    }
  ],

  "Mode et Accessoires" => [
    {
      name: "Sac à main Louis Vuitton",
      description: "Sac Louis Vuitton Neverfull MM en toile monogram et cuir naturel. Authentique, avec certificat d'authenticité. Très bon état général.",
      price: 1250.00
    },
    {
      name: "Montre Rolex Submariner",
      description: "Rolex Submariner Date réf. 116610LN. Montre automatique en acier inoxydable. Révisée récemment, papiers d'origine. État exceptionnel.",
      price: 8900.00
    },
    {
      name: "Baskets Nike Air Jordan 1",
      description: "Nike Air Jordan 1 Retro High OG 'Bred Toe' taille 42. État neuf, portées 2-3 fois seulement. Boîte d'origine incluse.",
      price: 189.99
    },
    {
      name: "Manteau Canada Goose",
      description: "Parka Canada Goose Expedition taille M. Doudoune grand froid authentic. Parfait pour l'hiver, très chaud et résistant.",
      price: 650.00
    },
    {
      name: "Lunettes Ray-Ban Aviator",
      description: "Lunettes de soleil Ray-Ban Aviator Classic or avec verres verts G-15. Très bon état, étui inclus. Modèle iconique intemporel.",
      price: 89.99
    }
  ],

  "Maison et Jardin" => [
    {
      name: "Canapé 3 places en cuir",
      description: "Canapé 3 places en cuir véritable couleur cognac. Design moderne et confortable. Excellent état, non fumeur, pas d'animaux. Dimensions: 200x90x85 cm.",
      price: 899.00
    },
    {
      name: "Cafetière Nespresso Vertuo",
      description: "Machine à café Nespresso Vertuo Plus en excellent état. Utilisée pendant 1 an, détartrée régulièrement. Livré avec 40 capsules.",
      price: 89.00
    },
    {
      name: "Table à manger en chêne",
      description: "Table à manger en chêne massif pour 6 personnes. Finition huilée naturelle. Dimensions: 180x90 cm. Quelques micro-rayures d'usage.",
      price: 450.00
    },
    {
      name: "Aspirateur Dyson V11",
      description: "Aspirateur sans fil Dyson V11 Absolute avec tous les accessoires. Batterie longue durée, aspiration puissante. Très bon état de fonctionnement.",
      price: 399.00
    },
    {
      name: "Barbecue Weber Genesis",
      description: "Barbecue à gaz Weber Genesis II E-310 3 brûleurs. Excellent état, très peu utilisé. Parfait pour les grillades en famille ou entre amis.",
      price: 589.00
    }
  ],

  "Véhicules" => [
    {
      name: "Vélo électrique Giant",
      description: "VTT électrique Giant Trance E+ Pro avec batterie 625 Wh. Parfait état, révisé récemment. Idéal pour randonnées et trajets urbains.",
      price: 2899.00
    },
    {
      name: "Trottinette Xiaomi Mi",
      description: "Trottinette électrique Xiaomi Mi Electric Scooter Pro 2. Autonomie 45 km, vitesse max 25 km/h. Bon état général, quelques micro-rayures.",
      price: 289.00
    },
    {
      name: "Vélo de route Specialized",
      description: "Vélo de route Specialized Allez Sprint taille 54. Groupe Shimano 105, excellent état. Parfait pour cyclisme sportif et compétition amateur.",
      price: 1199.00
    }
  ],

  "Sports et Loisirs" => [
    {
      name: "Raquette de tennis Wilson",
      description: "Raquette Wilson Pro Staff RF97 Autograph. Modèle signature Roger Federer. Excellente raquette pour joueurs confirmés. Très bon état.",
      price: 189.00
    },
    {
      name: "Planche de surf 6'2\"",
      description: "Planche de surf 6'2\" performance. Shape moderne, idéale pour surfeurs intermédiaires. Quelques petits dings réparés, étanche.",
      price: 350.00
    },
    {
      name: "Set de golf Callaway",
      description: "Set complet de golf Callaway avec sac. Driver, fers, wedges et putter inclus. Parfait pour débuter ou se perfectionner.",
      price: 599.00
    },
    {
      name: "Appareil de musculation",
      description: "Banc de musculation multifonction avec haltères et disques. Compact et robuste, parfait pour home gym. Très bon état général.",
      price: 299.00
    }
  ],

  "Livres et Culture" => [
    {
      name: "Collection Harry Potter",
      description: "Collection complète Harry Potter en français, édition reliée. 7 tomes en excellent état. Parfait cadeau pour enfant ou adulte nostalgique.",
      price: 89.00
    },
    {
      name: "Guitare Martin D-28",
      description: "Guitare acoustique Martin D-28. Son exceptionnel, bois de qualité premium. Quelques marques d'usage mais excellent état de jeu.",
      price: 1899.00
    },
    {
      name: "Vinyles collection Jazz",
      description: "Collection de 25 vinyles Jazz classique (Miles Davis, John Coltrane, etc.). Très bon état général, pochettes préservées.",
      price: 199.00
    }
  ]
}

# Compteur pour le tracking
total_products = 0

categories_produits.each do |categorie, produits|
  puts "Création des produits pour la catégorie: #{categorie}..."

  produits.each do |produit_data|
    # Attribution aléatoire à un utilisateur
    user = [admin, *users].sample

    # Création du produit
    product = Product.create!(
      name: produit_data[:name],
      description: produit_data[:description],
      price: produit_data[:price],
      user: user,
      views_count: rand(5..150), # Vues aléatoires réalistes
      sold: [true, false, false, false, false].sample, # 20% de chance d'être vendu
      created_at: rand(3.months.ago..Time.current) # Dates de création étalées
    )

    total_products += 1
  end
end

puts "#{total_products} produits créés avec succès"

# ========================================
# PRODUITS SPÉCIAUX POUR DÉMO
# ========================================

puts "Création de produits de démonstration spéciaux..."

# Produits populaires avec beaucoup de vues
demo_products = [
  {
    name: "Tesla Model 3 Occasion 2021",
    description: "Tesla Model 3 Long Range 2021, 45 000 km. Autopilot, superchargeur gratuit. Batterie excellente autonomie 500+ km. Véhicule exceptionnel.",
    price: 38900.00,
    views_count: 1247,
    sold: false
  },
  {
    name: "Appartement T2 - Location courte durée",
    description: "Bel appartement T2 centre-ville, entièrement meublé et équipé. Balcon, parking. Idéal pour séjours professionnels ou touristiques.",
    price: 85.00,
    views_count: 892,
    sold: false
  },
  {
    name: "Cours particuliers de mathématiques",
    description: "Professeur agrégé propose cours particuliers tous niveaux. Préparation bac, concours, soutien scolaire. Résultats garantis.",
    price: 45.00,
    views_count: 234,
    sold: false
  }
]

demo_products.each do |demo_data|
  Product.create!(
    name: demo_data[:name],
    description: demo_data[:description],
    price: demo_data[:price],
    user: admin,
    views_count: demo_data[:views_count],
    sold: demo_data[:sold],
    created_at: rand(1.week.ago..Time.current)
  )
end

puts "3 produits de démonstration créés"

# ========================================
# STATISTIQUES FINALES
# ========================================

puts ""
puts "=" * 50
puts "SEEDING TERMINÉ AVEC SUCCÈS"
puts "=" * 50
puts ""
puts "STATISTIQUES:"
puts "- Utilisateurs créés: #{User.count}"
puts "- Produits créés: #{Product.count}"
puts "- Produits disponibles: #{Product.where(sold: false).count}"
puts "- Produits vendus: #{Product.where(sold: true).count}"
puts "- Prix moyen: #{Product.average(:price).round(2)}€"
puts "- Produit le plus cher: #{Product.maximum(:price)}€"
puts "- Produit le moins cher: #{Product.minimum(:price)}€"
puts ""
puts "UTILISATEURS DE TEST:"
puts "- Admin: admin@innovaition.cloud (mot de passe: password)"
puts "- Vendeurs: marie.dubois@email.com, thomas.martin@email.com, etc."
puts "- Tous les mots de passe: password"
puts ""
puts "Vous pouvez maintenant démarrer l'application:"
puts "rails server"
puts ""
