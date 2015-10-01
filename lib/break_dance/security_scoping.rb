module BreakDance
  module SecurityScoping
    extend ActiveSupport::Concern

    module ClassMethods
      def scoped(options = nil)
        scope = super(options)
        return ActiveRecord::Relation.new(self, Arel::Table.new(table_name)) unless scope

        sph = RequestStore.store[:security_policy_holder]
        if sph
          if sph.suppress_security_for == self.name
            sph.suppress_security_for = nil
            scope
          else
            scope.merge(sph.policies[self.name]).readonly(false)
          end
        else
          scope
        end
      end

      def realy_unsecured
        RequestStore.store[:security_policy_holder].suppress_security_for = self.name if RequestStore.store[:security_policy_holder]
        self
      end

      def unsecured
        if RequestStore.store[:security_policy_holder]
          RequestStore.store[:security_policy_holder].suppress_security_for = self.name
          scoped
        else
          self
        end
      end
    end
  end
end
