module FavoritesHelper
  def favorite_button(product)
    if user_signed_in?
      if current_user.favorites.exists?(product: product)
        # Bouton pour retirer des favoris
        button_to unfavorite_product_path(product),
                  method: :delete,
                  form: { data: { turbo: false } },
                  class: "btn-favorite favorited",
                  title: "Retirer des favoris" do
          content_tag :i, "", class: "fas fa-heart"
        end
      else
        # Bouton pour ajouter aux favoris
        button_to favorite_product_path(product),
                  method: :post,
                  form: { data: { turbo: false } },
                  class: "btn-favorite",
                  title: "Ajouter aux favoris" do
          content_tag :i, "", class: "far fa-heart"
        end
      end
    else
      # Utilisateur non connecté
      link_to new_user_session_path,
              class: "btn-favorite",
              title: "Se connecter pour ajouter aux favoris" do
        content_tag :i, "", class: "far fa-heart"
      end
    end
  end
end
