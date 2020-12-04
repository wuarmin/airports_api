module Models
  class User < Sequel::Model(DB[Sequel[:public][:users]])
    dataset_module do
      def find_by_email(email)
        where(email: email).first
      end
    end
  end
end

