# db/seeds.rb - Seeds professionnels avec images Cloudinary depuis Unsplash
require 'open-uri'

puts "🧹 Nettoyage de la base de données..."
Order.destroy_all
Favorite.destroy_all
Product.destroy_all
User.destroy_all

puts "✅ Base de données nettoyée"

# ========================================
# 👥 CRÉATION DES UTILISATEURS
# ========================================

puts "👥 Création des utilisateurs..."

admin = User.create!(
  email: "admin@innovaition.cloud",
  password: "password",
  password_confirmation: "password"
)

vendeurs_data = [
  { email: "marie.dubois@email.com" },
  { email: "thomas.martin@email.com" },
  { email: "sophie.bernard@email.com" },
  { email: "lucas.petit@email.com" },
  { email: "emma.garcia@email.com" },
  { email: "antoine.roux@email.com" },
  { email: "julie.moreau@email.com" },
  { email: "maxime.laurent@email.com" }
]

users = vendeurs_data.map do |vendeur|
  User.create!(
    email: vendeur[:email],
    password: "password",
    password_confirmation: "password"
  )
end

puts "✅ #{users.count + 1} utilisateurs créés"

# ========================================
# 📦 CRÉATION DES PRODUITS AVEC PHOTOS
# ========================================

puts "📦 Création des produits avec images Unsplash..."

# Fonction helper pour attacher des images depuis Unsplash
def attach_images(product, image_urls)
  image_urls.each_with_index do |url, index|
    begin
      file = URI.open(url)
      product.photos.attach(
        io: file,
        filename: "#{product.name.parameterize}-#{index + 1}.jpg",
        content_type: 'image/jpeg'
      )
      print "."
    rescue => e
      puts "\n⚠️  Erreur lors du chargement de l'image #{index + 1} pour #{product.name}: #{e.message}"
    end
  end
end

# ÉLECTRONIQUE
puts "\n📱 Électronique..."

product = Product.create!(
  name: "iPhone 14 Pro - Occasion",
  description: "iPhone 14 Pro de 256 Go en excellent état. Utilisé pendant 6 mois avec protection écran et coque. Batterie à 95%. Livré avec chargeur d'origine et boîte.",
  price: 899.99,
  user: users.sample,
  views_count: rand(50..200),
  sold: false
)
attach_images(product, [
  "https://images.unsplash.com/photo-1678685888221-cda773a3dcdb?w=800",
  "https://images.unsplash.com/photo-1663499482523-1c0d9b0c6edb?w=800",
  "https://images.unsplash.com/photo-1592286927505-683ed4ed1ed1?w=800"
])

product = Product.create!(
  name: "MacBook Air M2 2022",
  description: "MacBook Air 13 pouces avec puce M2, 8 Go de RAM et 256 Go SSD. Parfait état, très peu utilisé. Idéal pour étudiants ou professionnels nomades.",
  price: 1199.00,
  user: users.sample,
  views_count: rand(50..200),
  sold: false
)
attach_images(product, [
  "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800",
  "https://images.unsplash.com/photo-1611186871348-b1ce696e52c9?w=800"
])

product = Product.create!(
  name: "Samsung Galaxy S23",
  description: "Samsung Galaxy S23 128 Go noir fantôme. État impeccable, toujours sous garantie jusqu'en mars 2025. Écran sans rayure, fonctionnement parfait.",
  price: 649.50,
  user: users.sample,
  views_count: rand(50..200),
  sold: false
)
attach_images(product, [
  "https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=800",
  "https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=800"
])

product = Product.create!(
  name: "Nintendo Switch OLED",
  description: "Console Nintendo Switch modèle OLED avec Joy-Con néon. Très bon état, peu utilisée. Livrée avec dock, câbles et 3 jeux inclus.",
  price: 289.99,
  user: users.sample,
  views_count: rand(50..200),
  sold: false
)
attach_images(product, [
  "https://images.unsplash.com/photo-1578303512597-81e6cc155b3e?w=800",
  "https://images.unsplash.com/photo-1486401899868-0e435ed85128?w=800"
])

product = Product.create!(
  name: "iPad Air 5ème génération",
  description: "iPad Air M1 64 Go Wi-Fi couleur gris sidéral. Excellent état, utilisé principalement pour la lecture. Livré avec Apple Pencil de 2ème génération.",
  price: 449.00,
  user: users.sample,
  views_count: rand(50..200),
  sold: false
)
attach_images(product, [
  "https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=800",
  "https://images.unsplash.com/photo-1561154464-82e9adf32764?w=800"
])

product = Product.create!(
  name: "AirPods Pro 2ème génération",
  description: "AirPods Pro avec réduction de bruit active et boîtier de charge sans fil. Neufs, jamais déballés. Garantie Apple complète.",
  price: 249.00,
  user: users.sample,
  views_count: rand(50..200),
  sold: false
)
attach_images(product, [
  "https://images.unsplash.com/photo-1606841837239-c5a1a4a07af7?w=800",
  "https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?w=800"
])

# MODE ET ACCESSOIRES
puts "\n👗 Mode et Accessoires..."

product = Product.create!(
  name: "Sac à main Louis Vuitton",
  description: "Sac Louis Vuitton Neverfull MM en toile monogram et cuir naturel. Authentique, avec certificat d'authenticité. Très bon état général.",
  price: 1250.00,
  user: users.sample,
  views_count: rand(50..200),
  sold: false
)
attach_images(product, [
  "https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=800",
  "https://images.unsplash.com/photo-1591561954557-26941169b49e?w=800"
])

product = Product.create!(
  name: "Montre Rolex Submariner",
  description: "Rolex Submariner Date réf. 116610LN. Montre automatique en acier inoxydable. Révisée récemment, papiers d'origine. État exceptionnel.",
  price: 8900.00,
  user: users.sample,
  views_count: rand(100..300),
  sold: false
)
attach_images(product, [
  "https://images.unsplash.com/photo-1523170335258-f5ed11844a49?w=800",
  "https://images.unsplash.com/photo-1587836374873-60d95fd4ffe9?w=800"
])

product = Product.create!(
  name: "Baskets Nike Air Jordan 1",
  description: "Nike Air Jordan 1 Retro High OG 'Bred Toe' taille 42. État neuf, portées 2-3 fois seulement. Boîte d'origine incluse.",
  price: 189.99,
  user: users.sample,
  views_count: rand(50..200),
  sold: false
)
attach_images(product, [
  "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800",
  "https://images.unsplash.com/photo-1460353581641-37baddab0fa2?w=800"
])

product = Product.create!(
  name: "Manteau Canada Goose",
  description: "Parka Canada Goose Expedition taille M. Doudoune grand froid authentic. Parfait pour l'hiver, très chaud et résistant.",
  price: 650.00,
  user: users.sample,
  views_count: rand(50..200),
  sold: false
)
attach_images(product, [
  "https://images.unsplash.com/photo-1539533113208-f6df8cc8b543?w=800",
  "https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=800"
])

product = Product.create!(
  name: "Lunettes Ray-Ban Aviator",
  description: "Lunettes de soleil Ray-Ban Aviator Classic or avec verres verts G-15. Très bon état, étui inclus. Modèle iconique intemporel.",
  price: 89.99,
  user: users.sample,
  views_count: rand(30..150),
  sold: false
)
attach_images(product, [
  "https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=800",
  "https://images.unsplash.com/photo-1473496169904-658ba7c44d8a?w=800"
])

# MAISON ET JARDIN
puts "\n🏠 Maison et Jardin..."

product = Product.create!(
  name: "Canapé 3 places en cuir",
  description: "Canapé 3 places en cuir véritable couleur cognac. Design moderne et confortable. Excellent état, non fumeur, pas d'animaux. Dimensions: 200x90x85 cm.",
  price: 899.00,
  user: users.sample,
  views_count: rand(50..200),
  sold: false
)
attach_images(product, [
  "https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800",
  "https://images.unsplash.com/photo-1493663284031-b7e3aefcae8e?w=800"
])

product = Product.create!(
  name: "Cafetière Nespresso Vertuo",
  description: "Machine à café Nespresso Vertuo Plus en excellent état. Utilisée pendant 1 an, détartrée régulièrement. Livré avec 40 capsules.",
  price: 89.00,
  user: users.sample,
  views_count: rand(30..150),
  sold: false
)
attach_images(product, [
  "https://images.unsplash.com/photo-1517668808822-9ebb02f2a0e6?w=800",
  "https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=800"
])

product = Product.create!(
  name: "Table à manger en chêne",
  description: "Table à manger en chêne massif pour 6 personnes. Finition huilée naturelle. Dimensions: 180x90 cm. Quelques micro-rayures d'usage.",
  price: 450.00,
  user: users.sample,
  views_count: rand(50..200),
  sold: false
)
attach_images(product, [
  "https://images.unsplash.com/photo-1617806118233-18e1de247200?w=800",
  "https://images.unsplash.com/photo-1595428774223-ef52624120d2?w=800"
])

product = Product.create!(
  name: "Aspirateur Dyson V11",
  description: "Aspirateur sans fil Dyson V11 Absolute avec tous les accessoires. Batterie longue durée, aspiration puissante. Très bon état de fonctionnement.",
  price: 399.00,
  user: users.sample,
  views_count: rand(50..200),
  sold: false
)
attach_images(product, [
  "https://images.unsplash.com/photo-1558317374-067fb5f30001?w=800"
])

product = Product.create!(
  name: "Barbecue Weber Genesis",
  description: "Barbecue à gaz Weber Genesis II E-310 3 brûleurs. Excellent état, très peu utilisé. Parfait pour les grillades en famille ou entre amis.",
  price: 589.00,
  user: users.sample,
  views_count: rand(50..200),
  sold: false
)
attach_images(product, [
  "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800",
  "https://images.unsplash.com/photo-1603039861131-e03f1e65238a?w=800"
])

# VÉHICULES
puts "\n🚴 Véhicules..."

product = Product.create!(
  name: "Vélo électrique Giant",
  description: "VTT électrique Giant Trance E+ Pro avec batterie 625 Wh. Parfait état, révisé récemment. Idéal pour randonnées et trajets urbains.",
  price: 2899.00,
  user: users.sample,
  views_count: rand(100..300),
  sold: false
)
attach_images(product, [
  "https://images.unsplash.com/photo-1571068316344-75bc76f77890?w=800",
  "https://images.unsplash.com/photo-1532298229144-0ec0c57515c7?w=800"
])

product = Product.create!(
  name: "Trottinette Xiaomi Mi",
  description: "Trottinette électrique Xiaomi Mi Electric Scooter Pro 2. Autonomie 45 km, vitesse max 25 km/h. Bon état général, quelques micro-rayures.",
  price: 289.00,
  user: users.sample,
  views_count: rand(50..200),
  sold: false
)
attach_images(product, [
  "https://images.unsplash.com/photo-1559311785-69d9d5450738?w=800"
])

product = Product.create!(
  name: "Vélo de route Specialized",
  description: "Vélo de route Specialized Allez Sprint taille 54. Groupe Shimano 105, excellent état. Parfait pour cyclisme sportif et compétition amateur.",
  price: 1199.00,
  user: users.sample,
  views_count: rand(50..200),
  sold: false
)
attach_images(product, [
  "https://images.unsplash.com/photo-1576435728678-68d0fbf94e91?w=800",
  "https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=800"
])

# SPORTS ET LOISIRS
puts "\n⚽ Sports et Loisirs..."

product = Product.create!(
  name: "Raquette de tennis Wilson",
  description: "Raquette Wilson Pro Staff RF97 Autograph. Modèle signature Roger Federer. Excellente raquette pour joueurs confirmés. Très bon état.",
  price: 189.00,
  user: users.sample,
  views_count: rand(30..150),
  sold: false
)
attach_images(product, [
  "https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=800",
  "https://images.unsplash.com/photo-1617083684388-9e0d537c18c1?w=800"
])

product = Product.create!(
  name: "Planche de surf 6'2\"",
  description: "Planche de surf 6'2\" performance. Shape moderne, idéale pour surfeurs intermédiaires. Quelques petits dings réparés, étanche.",
  price: 350.00,
  user: users.sample,
  views_count: rand(50..200),
  sold: false
)
attach_images(product, [
  "https://images.unsplash.com/photo-1502933691298-84fc14542831?w=800",
  "https://images.unsplash.com/photo-1455264745730-cb4c7e1f7e5f?w=800"
])

product = Product.create!(
  name: "Set de golf Callaway",
  description: "Set complet de golf Callaway avec sac. Driver, fers, wedges et putter inclus. Parfait pour débuter ou se perfectionner.",
  price: 599.00,
  user: users.sample,
  views_count: rand(50..200),
  sold: false
)
attach_images(product, [
  "https://images.unsplash.com/photo-1535131749006-b7f58c99034b?w=800",
  "https://images.unsplash.com/photo-1587174486073-ae5e5cff23aa?w=800"
])

product = Product.create!(
  name: "Appareil de musculation",
  description: "Banc de musculation multifonction avec haltères et disques. Compact et robuste, parfait pour home gym. Très bon état général.",
  price: 299.00,
  user: users.sample,
  views_count: rand(50..200),
  sold: false
)
attach_images(product, [
  "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800",
  "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800"
])

# LIVRES ET CULTURE
puts "\n📚 Livres et Culture..."

product = Product.create!(
  name: "Collection Harry Potter",
  description: "Collection complète Harry Potter en français, édition reliée. 7 tomes en excellent état. Parfait cadeau pour enfant ou adulte nostalgique.",
  price: 89.00,
  user: users.sample,
  views_count: rand(50..200),
  sold: false
)
attach_images(product, [
  "https://images.unsplash.com/photo-1621351183012-e2f9972dd9bf?w=800",
  "https://images.unsplash.com/photo-1618365908648-e71bd5716cba?w=800"
])

product = Product.create!(
  name: "Guitare Martin D-28",
  description: "Guitare acoustique Martin D-28. Son exceptionnel, bois de qualité premium. Quelques marques d'usage mais excellent état de jeu.",
  price: 1899.00,
  user: users.sample,
  views_count: rand(100..300),
  sold: false
)
attach_images(product, [
  "https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=800",
  "https://images.unsplash.com/photo-1516924962500-2b4b3b99ea02?w=800"
])

product = Product.create!(
  name: "Vinyles collection Jazz",
  description: "Collection de 25 vinyles Jazz classique (Miles Davis, John Coltrane, etc.). Très bon état général, pochettes préservées.",
  price: 199.00,
  user: users.sample,
  views_count: rand(50..200),
  sold: false
)
attach_images(product, [
  "https://images.unsplash.com/photo-1603048588665-791ca8aea617?w=800",
  "https://images.unsplash.com/photo-1496293455970-f8581aae0e3b?w=800"
])

# PRODUITS DE DÉMO AVEC BEAUCOUP DE VUES
puts "\n⭐ Produits de démonstration..."

product = Product.create!(
  name: "Tesla Model 3 Occasion 2021",
  description: "Tesla Model 3 Long Range 2021, 45 000 km. Autopilot, superchargeur gratuit. Batterie excellente autonomie 500+ km. Véhicule exceptionnel.",
  price: 38900.00,
  user: admin,
  views_count: 1247,
  sold: false
)
attach_images(product, [
  "https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=800",
  "https://images.unsplash.com/photo-1617788138017-80ad40651399?w=800",
  "https://images.unsplash.com/photo-1536700503339-1e4b06520771?w=800"
])

product = Product.create!(
  name: "Appartement T2 - Location courte durée",
  description: "Bel appartement T2 centre-ville, entièrement meublé et équipé. Balcon, parking. Idéal pour séjours professionnels ou touristiques.",
  price: 85.00,
  user: admin,
  views_count: 892,
  sold: false
)
attach_images(product, [
  "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800",
  "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800"
])

product = Product.create!(
  name: "Cours particuliers de mathématiques",
  description: "Professeur agrégé propose cours particuliers tous niveaux. Préparation bac, concours, soutien scolaire. Résultats garantis.",
  price: 45.00,
  user: admin,
  views_count: 234,
  sold: false
)
attach_images(product, [
  "https://images.unsplash.com/photo-1509228627152-72ae9ae6848d?w=800"
])

puts "\n"
puts "=" * 60
puts "🎉 SEEDING TERMINÉ AVEC SUCCÈS !"
puts "=" * 60
puts ""
puts "📊 STATISTIQUES :"
puts "- Utilisateurs: #{User.count}"
puts "- Produits: #{Product.count}"
puts "- Photos attachées: #{ActiveStorage::Attachment.count}"
puts "- Produits disponibles: #{Product.where(sold: false).count}"
puts "- Prix moyen: #{Product.average(:price).round(2)}€"
puts ""
puts "👤 COMPTES DE TEST :"
puts "- admin@innovaition.cloud (password: password)"
puts "- marie.dubois@email.com (password: password)"
puts ""
puts "🚀 Lancer l'application : rails server"
puts ""
