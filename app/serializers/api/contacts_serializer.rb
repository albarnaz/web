class Api::ContactsSerializer < ActiveModel::Serializer

  class Api::ContactsSerializer::Show < ActiveModel::Serializer
    attributes(:email, :name, :text, :avatar)
    attribute(:users) { object.users.collect{|u| u.firstname + ' ' + u.lastname} }
  end

  class Api::ContactsSerializer::Index < ActiveModel::Serializer
<<<<<<< HEAD
    attributes(:email, :name, :text, :avatar)
=======
    attributes(:id, :email, :name, :text, :avatar)
>>>>>>> 10c48023... Include avatar and names in contact API
    attribute(:users) { object.users.collect{|u| u.firstname + ' ' + u.lastname} }

    def text
      MarkdownHelper.markdown_api(object.text)
    end
  end
end
