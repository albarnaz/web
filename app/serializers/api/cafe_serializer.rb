class Api::CafeSerializer < ActiveModel::Serializer

  class Api::CafeSerializer::Index < ActiveModel::Serializer
    attributes(:id, :start, :pass)
    has_one :user

    class Api::UserSerializer < ActiveModel::Serializer
      attributes(:id, :name)
      def name
        "#{object.firstname} #{object.lastname}"
      end
    end
  end
end
